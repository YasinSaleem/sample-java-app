package com.example;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest(classes = SampleJavaAppApplication.class)
@TestPropertySource(properties = {
    "management.endpoints.web.exposure.include=health,info"
})
public class HelloControllerTest {

    @Test
    public void contextLoads() {
        // This test will pass if the Spring context loads successfully
    }
}