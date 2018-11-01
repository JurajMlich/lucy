package eu.mlich.lucy.dto

import eu.mlich.lucy.model.finance.FinanceTransactionState
import java.time.LocalDateTime
import java.util.*

/**
 * @author Juraj Mlich <jurajmlich@gmail.com>
 */
data class FinanceTransactionDto(
        var id: UUID? = null,
        var sourceDepositId: UUID?,
        var targetDepositId: UUID?,
        var state: FinanceTransactionState,
        var value: Double,
        var executionDatetime: LocalDateTime?,
        val creatorId: UUID,
        var name: String? = null,
        var note: String? = null,
        var categoriesIds: Set<UUID> = HashSet()
)