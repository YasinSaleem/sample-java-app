package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
  @GetMapping("/")
  public String hello() {
    return "Hello from EKS!";
  }
  
  @GetMapping("/version")
  public String version() {
    return "Sample Java App v1.1 - CI/CD Pipeline Ready!";
  }
  
  @GetMapping("/health-simple")
  public String healthCheck() {
    return "Application is running successfully on Kubernetes!";
  }
}
