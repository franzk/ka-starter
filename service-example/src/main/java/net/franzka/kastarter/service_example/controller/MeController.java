package net.franzka.kastarter.service_example.controller;

import net.franzka.kastarter.service_example.domain.dto.MeDto;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MeController {
    @GetMapping("/me")
    public MeDto me(@AuthenticationPrincipal Jwt jwt) {
        return MeDto.builder()
                .name(jwt.getClaimAsString("preferred_username"))
                .email(jwt.getClaimAsString("email"))
                .build();
    }
}
