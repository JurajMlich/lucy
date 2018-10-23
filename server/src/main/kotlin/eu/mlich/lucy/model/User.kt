package eu.mlich.lucy.model

import java.util.*
import javax.persistence.*

/**
 * Represent a user that uses the application.
 *
 * @author Juraj Mlich <jurajmlich@gmail.com>
 */
@Entity
@Table(name = "`user`")
data class User(
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        @Column(name = "id")
        var id: Int? = null,

        @Column(name = "email")
        val email: String?,

        @Column(name = "password")
        var password: String?,

        @Column(name = "first_name")
        var firstName: String?,

        @Column(name = "last_name")
        var lastName: String?,

        @Column(name = "public_key")
        var publicKey: UUID = UUID.randomUUID()

) {
    override fun equals(other: Any?) = other is User && other.publicKey === publicKey

    override fun hashCode(): Int = publicKey.hashCode()
}
