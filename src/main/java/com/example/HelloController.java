package com.example;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @GetMapping("/")
    public String hello() {
        return "Hi world from yasin";
    }

    @GetMapping("/version")
    public String version() {
        return "Sample Java App - Version 1.0.0";
    }

    @GetMapping("/health-simple")
    public String healthSimple() {
        return "OK - Application is running!";
    }
}