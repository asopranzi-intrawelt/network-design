// Client HTTPS circoscritto allo snapshot Proxmox. Nessun bypass TLS globale.
using System;
using System.Net;
using System.Net.Http;
using System.Net.Security;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;

public sealed class ProxmoxHttpStatusException : Exception
{
    public int StatusCode { get; private set; }
    public ProxmoxHttpStatusException(int statusCode) : base("Stato HTTP Proxmox: " + statusCode)
    {
        StatusCode = statusCode;
    }
}

public sealed class ProxmoxVerifiedHttp : IDisposable
{
    private readonly string host;
    private readonly int port;
    private readonly byte[] caBytes;
    private readonly string caPin;
    private readonly string leafPin;
    private readonly HttpClient client;

    public ProxmoxVerifiedHttp(string host, int port, byte[] caBytes, string caPin, string leafPin)
    {
        if (string.IsNullOrWhiteSpace(host) || port < 1 || port > 65535 || caBytes == null || caBytes.Length == 0 ||
            !IsHash(caPin) || !IsHash(leafPin)) throw new ArgumentException("Parametri TLS privati assenti o non validi.");
        this.host = host;
        this.port = port;
        this.caBytes = (byte[])caBytes.Clone();
        this.caPin = caPin.ToLowerInvariant();
        this.leafPin = leafPin.ToLowerInvariant();
        if (Hash(this.caBytes) != this.caPin) throw new ArgumentException("Impronta della CA privata non valida.");
        var handler = new HttpClientHandler { AllowAutoRedirect = false, UseCookies = false, UseProxy = false };
        handler.ServerCertificateCustomValidationCallback = Validate;
        client = new HttpClient(handler, true) { Timeout = TimeSpan.FromSeconds(30) };
    }

    private static bool IsHash(string value)
    {
        if (value == null || value.Length != 64) return false;
        foreach (char c in value) if (!Uri.IsHexDigit(c)) return false;
        return true;
    }

    private static string Hash(byte[] value)
    {
        using (var sha = SHA256.Create()) return BitConverter.ToString(sha.ComputeHash(value)).Replace("-", "").ToLowerInvariant();
    }

    // Publico per prove offline: il client reale usa questo stesso predicato.
    public bool Validate(HttpRequestMessage request, X509Certificate2 cert, X509Chain ignored, SslPolicyErrors errors)
    {
        if (request == null || request.RequestUri == null || cert == null ||
            request.RequestUri.Scheme != Uri.UriSchemeHttps ||
            !string.Equals(request.RequestUri.Host, host, StringComparison.OrdinalIgnoreCase) ||
            request.RequestUri.Port != port ||
            (errors & (SslPolicyErrors.RemoteCertificateNameMismatch | SslPolicyErrors.RemoteCertificateNotAvailable)) != 0 ||
            Hash(cert.RawData) != leafPin ||
            cert.NotBefore.ToUniversalTime() > DateTime.UtcNow || cert.NotAfter.ToUniversalTime() < DateTime.UtcNow)
            return false;

        using (var ca = new X509Certificate2(caBytes))
        using (var chain = new X509Chain())
        {
            chain.ChainPolicy.ExtraStore.Add(ca);
            chain.ChainPolicy.VerificationFlags = X509VerificationFlags.AllowUnknownCertificateAuthority;
            chain.ChainPolicy.RevocationMode = X509RevocationMode.NoCheck;
            chain.ChainPolicy.ApplicationPolicy.Add(new Oid("1.3.6.1.5.5.7.3.1"));
            if (!chain.Build(cert) || chain.ChainElements.Count == 0) return false;
            var root = chain.ChainElements[chain.ChainElements.Count - 1].Certificate;
            return Hash(root.RawData) == caPin;
        }
    }

    public string Send(string url, string method, string authorization, string cookie, string body)
    {
        var uri = new Uri(url, UriKind.Absolute);
        if (uri.Scheme != Uri.UriSchemeHttps || !string.Equals(uri.Host, host, StringComparison.OrdinalIgnoreCase) || uri.Port != port)
            throw new ArgumentException("URL fuori dal nodo verificato.");
        if (method != "GET" && method != "POST") throw new ArgumentException("Metodo HTTP non ammesso.");
        using (var req = new HttpRequestMessage(new HttpMethod(method), uri))
        {
            if (!string.IsNullOrEmpty(authorization)) req.Headers.TryAddWithoutValidation("Authorization", authorization);
            if (!string.IsNullOrEmpty(cookie)) req.Headers.TryAddWithoutValidation("Cookie", "PVEAuthCookie=" + cookie);
            if (method == "POST")
            {
                if (string.IsNullOrEmpty(body)) throw new ArgumentException("Corpo POST assente.");
                req.Content = new StringContent(body, System.Text.Encoding.UTF8, "application/x-www-form-urlencoded");
            }
            using (var resp = client.SendAsync(req).GetAwaiter().GetResult())
            {
                if (!resp.IsSuccessStatusCode) throw new ProxmoxHttpStatusException((int)resp.StatusCode);
                return resp.Content.ReadAsStringAsync().GetAwaiter().GetResult();
            }
        }
    }

    public void Dispose() { client.Dispose(); }
}
