#  Chain building Symantec timestamping certificate chain on macOS
This app demonstrates X.509 chain building of a Symantec timestamping certificate chain on macOS.

Chain building fails because the timestamping "certificate is blocked."

The certificate chain is:

Level | crt.sh | SHA-1 | SHA-256 | Subject
--- | --- | --- | --- | ---
root | [view](https://crt.sh/?id=1039083) | 3679ca35668772304d30a5fb873b0fa77bb70d54 | 2399561127a57125de8cefea610ddf2fa078b5c8067f4e828290bfb860e84b3c | CN=VeriSign Universal Root Certification Authority, OU="(c) 2008 VeriSign, Inc. - For authorized use only", OU=VeriSign Trust Network, O="VeriSign, Inc.", C=US
intermediate | [view](https://crt.sh/?id=157543221) | 6fc9edb5e00ab64151c1cdfcac74ad2c7b7e3be4 | f3516ddcc8afc808788bd8b0e840bda2b5e23c6244252ca3000bb6c87170402a | CN=Symantec SHA256 TimeStamping CA, OU=Symantec Trust Network, O=Symantec Corporation, C=US
end | [view](https://crt.sh/?id=1135145194) | a9a4121063d71d48e8529a4681de803e3e7954b0 | c474ce76007d02394e0da5e4de7c14c680f9e282013cfef653ef5db71fdf61f8 | CN=Symantec SHA256 TimeStamping Signer - G3, OU=Symantec Trust Network, O=Symantec Corporation, C=US

Running this app will print the following output:
```shell
SecTrustEvaluateWithError(...) failed.
Optional(Error Domain=NSOSStatusErrorDomain Code=-67820 "“Symantec SHA256 TimeStamping CA” certificate is blocked" UserInfo={NSLocalizedDescription=“Symantec SHA256 TimeStamping CA” certificate is blocked, NSUnderlyingError=0x105041cd0 {Error Domain=NSOSStatusErrorDomain Code=-67820 "Certificate 1 “Symantec SHA256 TimeStamping CA” has errors: Certificate is blocked;" UserInfo={NSLocalizedDescription=Certificate 1 “Symantec SHA256 TimeStamping CA” has errors: Certificate is blocked;}}})
TrustResultDetails=(
        {
    },
        {
        BlackListedLeaf = 0;
        StatusCodes =         (
            "-2147409652"
        );
    },
        {
    }
)
TrustEvaluationDate=2022-03-30 19:09:20 +0000
TrustResultValue=6

Program ended with exit code: 0
```

OSStatus -67820 is [`errSecCertificateRevoked`:  "The certificate was revoked."](https://github.com/apple-oss-distributions/Security/blob/154ef3d9d6f57f0374aa5d6c4b412e8653c1eebe/base/SecBase.h#L623).

Status code -2147409652 / 0x8001210C ([`BlackListedLeaf`](https://github.com/apple-oss-distributions/Security/blob/154ef3d9d6f57f0374aa5d6c4b412e8653c1eebe/OSX/sec/Security/SecPolicyChecks.list#L40)) applies to the intermediate CA.

[Information about distrusting Symantec certificate authorities](https://support.apple.com/en-us/HT208860) (HT208860) does not mention anything about this certificate chain.