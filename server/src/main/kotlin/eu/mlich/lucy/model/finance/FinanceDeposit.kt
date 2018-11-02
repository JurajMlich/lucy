package eu.mlich.lucy.model.finance

import eu.mlich.lucy.model.User
import java.util.*
import javax.persistence.*

/**
 * Represent a deposit of money (bank account, wallet).
 *
 * @author Juraj Mlich <jurajmlich@gmail.com>
 */
@Entity
@Table(name = "finance_deposit")
data class FinanceDeposit(
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

        @Column(name = "min_balance")
        var minBalance: Double?,

        @Column(name = "type")
        @Enumerated(EnumType.STRING)
        var type: FinanceDepositType,

        @ManyToMany(cascade = [CascadeType.ALL])
        @JoinTable(
                name = "finance_deposit_owner",
                joinColumns = [JoinColumn(name = "deposit_id")],
                inverseJoinColumns = [(JoinColumn(name = "user_id"))]
        )
        var owners: Set<User>,

        @ManyToMany(cascade = [CascadeType.ALL])
        @JoinTable(
                name = "finance_deposit_accessible_by",
                joinColumns = [JoinColumn(name = "deposit_id")],
                inverseJoinColumns = [(JoinColumn(name = "user_id"))]
        )
        var accessibleBy: Set<User> = HashSet(),

        @Column(name = "public_key")
        var publicKey: UUID = UUID.randomUUID()

) {
    override fun equals(other: Any?) = other is FinanceDeposit && other.publicKey === publicKey

    override fun hashCode(): Int = publicKey.hashCode()
}