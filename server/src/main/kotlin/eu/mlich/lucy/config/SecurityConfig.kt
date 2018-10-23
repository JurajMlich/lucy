package eu.mlich.lucy.config

import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter

// todo: implement

/**
 * Set up jwt authentication filters, access to endpoints, password encoder, authentication manager and user details
 * service.
 *
 * @author Juraj Mlich <jurajmlich@gmail.com>
 */
@Configuration
@EnableWebSecurity
class SecurityConfig : WebSecurityConfigurerAdapter() {
    override fun configure(http: HttpSecurity) {
        http.csrf().disable()
                .authorizeRequests()
                .anyRequest().permitAll()

    }
}