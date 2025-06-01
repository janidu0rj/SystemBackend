package com.sb.userservice.controller;

import com.sb.userservice.dto.AuthenticationResponse;
import com.sb.userservice.dto.LoginUserDTO;
import com.sb.userservice.dto.RegisterUserDTO;
import com.sb.userservice.model.Role;
import com.sb.userservice.model.User;
import com.sb.userservice.repository.UserRepository;
import com.sb.userservice.service.JWTService;
import com.sb.userservice.service.UserService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/user")
public class UserController {

    private final UserService userService;
    private final JWTService jwtService;
    private final UserRepository userRepository;

    public UserController(UserService userService, JWTService jwtService, UserRepository userRepository) {
        this.userService = userService;
        this.jwtService = jwtService;
        this.userRepository = userRepository;
    }

    @PostMapping("/auth/login")
    public ResponseEntity<AuthenticationResponse> loginUser(@Valid @RequestBody LoginUserDTO loginUserDTO) {
        AuthenticationResponse response = userService.loginUser(loginUserDTO);
        return ResponseEntity.ok(response);
    }

    // POST /user/register
    @PostMapping("/profile/register")
    public ResponseEntity<String> registerUser(@Valid @RequestBody RegisterUserDTO registerUserDTO, Authentication authentication) {
        String response = userService.registerUser(registerUserDTO, authentication);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/profile/validate")
    public ResponseEntity<Void> validateToken(@RequestHeader(HttpHeaders.AUTHORIZATION) String authHeader){
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.badRequest().build();
        }

        String token = authHeader.substring(7);
        String username = jwtService.extractUserName(token);

        Optional<User> userOptional = userRepository.findByUsername(username);
        if(userOptional.isEmpty()){
            return ResponseEntity.status(401).build(); // Unauthorized
        }

        UserDetails user = userOptional.get();

        if (jwtService.validateToken(token, user)) {
            return ResponseEntity.ok().build(); // Token is valid
        } else {
            return ResponseEntity.status(401).build(); // Unauthorized
        }
    }

    @GetMapping("/profile/role")
    public ResponseEntity<?> getRole(@RequestHeader(HttpHeaders.AUTHORIZATION) String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.badRequest().body("Missing or invalid Authorization header");
        }
        String token = authHeader.substring(7);
        try {
            Role role = userService.getRoleFromToken(token);
            return ResponseEntity.ok().body(Map.of("role", role.name()));
        } catch (Exception e) {
            return ResponseEntity.status(401).body("Invalid token or user not found");
        }
    }

    // PUT /user/update
    @PutMapping("/profile/update")
    public ResponseEntity<String> updateUser(@Valid @RequestBody RegisterUserDTO registerUserDTO, Authentication authentication) {
        String response = userService.updateUser(registerUserDTO, authentication);
        return ResponseEntity.ok(response);
    }

    // GET /user/get
    @GetMapping("/profile/get")
    public ResponseEntity<RegisterUserDTO> getUser(Authentication authentication) {
        RegisterUserDTO user = userService.getUser(authentication);
        return ResponseEntity.ok(user);
    }

    // DELETE /user/delete?username=...
    @DeleteMapping("/profile/delete")
    public ResponseEntity<String> deleteUser(@RequestParam @NotBlank String username, Authentication authentication) {
        String response = userService.deleteUser(username, authentication);
        return ResponseEntity.ok(response);
    }


}
