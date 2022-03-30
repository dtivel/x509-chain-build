//
//  main.swift
//  x509-chain-build
//
//  Created by Damon Tivel on 3/30/22.
//

import Security
import SecurityFoundation

let repro = Repro();

repro.Run();

public final class Repro {
    public func Run() {
        let rootCertificate: SecCertificate = loadCertificate(fileName: "root");
        let intermediateCertificate: SecCertificate = loadCertificate(fileName: "intermediate");
        let endCertificate: SecCertificate = loadCertificate(fileName: "end");

        let basicPolicy: SecPolicy = SecPolicyCreateBasicX509();
        let revocationPolicy: SecPolicy? = SecPolicyCreateRevocation(
            kSecRevocationUseAnyAvailableMethod | kSecRevocationRequirePositiveResponse
        );
        let policies: Array<SecPolicy> = [basicPolicy, revocationPolicy!];
        let certificates: Array<SecCertificate> = [endCertificate, intermediateCertificate, rootCertificate];
        let anchorCertificates: Array<SecCertificate> = [rootCertificate];
        var trust: SecTrust?;

        var status: OSStatus = SecTrustCreateWithCertificates(
            certificates as CFArray,
            policies as CFArray,
            &trust);
        
        if status != errSecSuccess {
            printErrorDetails(functionName: "SecTrustEvaluate", status: status);
            return;
        }
        
        status = SecTrustSetAnchorCertificates(trust!, anchorCertificates as CFArray);
        
        if status != errSecSuccess {
            printErrorDetails(functionName: "SecTrustSetAnchorCertificates", status: status);
            return;
        }
        
        status = SecTrustSetNetworkFetchAllowed(trust!, true);
        
        if status != errSecSuccess {
            printErrorDetails(functionName: "SecTrustSetNetworkFetchAllowed", status: status);
            return;
        }
        
        var error: CFError?;
        
        let result: Bool = SecTrustEvaluateWithError(trust!, &error);
        
        print("SecTrustEvaluateWithError(...) \(result ? "succeeded" : "failed").");
        
        if !result {
            print(error.debugDescription);
        }
        
        let trustResults = SecTrustCopyResult(trust!) as! [String: Any];
        
        for trustResult in trustResults {
            print("\(trustResult.key)=\(trustResult.value)");
        }
        
        print("");
    }

    private func loadCertificate(fileName: String) -> SecCertificate {
        let url: URL? = Bundle.main.url(forResource: fileName, withExtension: "cer");
        let data: Data? = try? Data(contentsOf: url!);
        let certificate: SecCertificate? = SecCertificateCreateWithData(kCFAllocatorDefault, data! as CFData);
        
        return certificate!;
    }

    private func printErrorDetails(functionName: String, status: OSStatus) {
        print("\(functionName)(...) failed with \(status).");
    
        if let message = SecCopyErrorMessageString(status, nil) {
            print(message);
        }
    }
}
