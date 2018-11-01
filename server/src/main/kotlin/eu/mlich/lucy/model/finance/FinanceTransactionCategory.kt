package eu.mlich.lucy.model.finance

import java.util.*
import javax.persistence.*

/**
 * Represent a category of transactions.
 *
 * @author Juraj Mlich <jurajmlich@gmail.com>
 */
@Entity
@Table(name = "finance_transaction_category")
data class FinanceTransactionCategory(
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        @Column(name = "id")
        var id: Int? = null,

        @Column(name = "name")
        var name: String,

        @Column(name = "color")
        var color: String? = null,

        /**
         * Used primarily for expenses?
         */
        @Column(name = "negative")
        var negative: Boolean,

        @Column(name = "disabled")
        var disabled: Boolean,

        @Column(name = "public_key")
        var publicKey: UUID = UUID.randomUUID()

) {
    override fun equals(other: Any?) = other is FinanceDeposit && other.publicKey === publicKey

    override fun hashCode(): Int = publicKey.hashCode()
}
