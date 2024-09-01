package com.shortlet.time.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/shortlet")
public class TimeController {

    @GetMapping("/time")
    public ResponseEntity<Map<String, String>> getTime() {

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm:ss");
        String formattedTime = LocalTime.now().format(formatter);

        Map<String, String> response = new HashMap<>();
        response.put("currentTime", formattedTime);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }
}
