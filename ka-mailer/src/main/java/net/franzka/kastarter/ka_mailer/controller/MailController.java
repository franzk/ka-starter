package net.franzka.kastarter.ka_mailer.controller;

import jakarta.mail.MessagingException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.franzka.kastarter.ka_mailer.dto.MailRequest;
import net.franzka.kastarter.ka_mailer.service.MailService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.UnsupportedEncodingException;

@RestController
@RequestMapping("/api/v1/mail")
@RequiredArgsConstructor
@Slf4j
public class
MailController {

    private final MailService mailService;

    @PostMapping
    public ResponseEntity<String> sendMail(@RequestBody @Valid MailRequest mailRequest) throws MessagingException, UnsupportedEncodingException {
        log.info("sendMail request : from {} to {} with subject {}", mailRequest.getFrom(), mailRequest.getTo(), mailRequest.getSubject());
        mailService.sendMail(mailRequest);
        return ResponseEntity.ok("Mail sent");
    }
}
