package com.bonigi.demo;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @Value("${app.version:dev}")
    private String version;

    @GetMapping("/")
    public Map<String, String> hello() throws UnknownHostException {
        return Map.of(
                "message", "Hello from AWS EKS",
                "version", version,
                "pod", InetAddress.getLocalHost().getHostName());
    }
}
