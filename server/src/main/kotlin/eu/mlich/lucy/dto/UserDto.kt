package eu.mlich.lucy.dto

import java.util.*

/**
 * DTO for [eu.mlich.lucy.model.User] that does not expose password.
 *
 * @author Juraj Mlich <jurajmlich@gmail.com>
 */
data class UserDto(
        var id: UUID?,
        val email: String?,
        val firstName: String?,
        val lastName: String?
)
