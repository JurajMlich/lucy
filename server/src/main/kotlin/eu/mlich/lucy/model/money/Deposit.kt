package eu.mlich.lucy.model.money

import eu.mlich.lucy.model.User
import org.hibernate.annotations.Type
import java.util.*
import javax.persistence.*

/**
 * Represent a deposit of money (bank account, wallet).
 *
 * @author Juraj Mlich <jurajmlich@gmail.com>
 */
@Entity
@Table(name = "deposit")
data class Deposit(
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        @Column(name = "id")
        var id: Int? = null,

        @Column(name = "`name`")
        var name: String,

        @Column(name = "balance")
        var balance: Double,

        @Column(name = "disabled")
        var disabled: Boolean,

        @Column(name = "type")
        @Enumerated(EnumType.STRING)
        var type: DepositType,

        @ManyToMany(cascade = [CascadeType.ALL])
        @JoinTable(
                name = "deposit_owner",
                joinColumns = [JoinColumn(name = "deposit_id")],
                inverseJoinColumns = [(JoinColumn(name = "user_id"))]
        )
        var owners: Set<User>,

        @ManyToMany(cascade = [CascadeType.ALL])
        @JoinTable(
                name = "deposit_user",
                joinColumns = [JoinColumn(name = "deposit_id")],
                inverseJoinColumns = [(JoinColumn(name = "user_id"))]
        )
        var accessibleBy: Set<User> = HashSet(),

        @Column(name = "public_key")
        var publicKey: UUID = UUID.randomUUID()

) {
    override fun equals(other: Any?) = other is Deposit && other.publicKey === publicKey

    override fun hashCode(): Int = publicKey.hashCode()
}