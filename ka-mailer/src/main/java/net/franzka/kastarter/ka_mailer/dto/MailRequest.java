package net.franzka.kastarter.ka_mailer.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class MailRequest {
    @NotBlank(message = "From address is mandatory")
    private String from;

    @NotBlank(message = "To address is mandatory")
    private String to;

    @NotBlank(message = "Subject is mandatory")
    private String subject;

    private String text;
    private String html;
}
