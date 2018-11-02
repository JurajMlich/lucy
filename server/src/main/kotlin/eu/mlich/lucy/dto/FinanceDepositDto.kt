package eu.mlich.lucy.dto

import eu.mlich.lucy.model.finance.FinanceDepositType
import java.util.*
import kotlin.collections.HashSet

data class FinanceDepositDto(
        var id: UUID? = null,
        var name: String,
        var balance: Double,
        var disabled: Boolean,
        var minBalance: Double?,
        var type: FinanceDepositType,
        var ownersIds: Set<UUID> = HashSet(),
        var accessibleByUsersIds: Set<UUID> = HashSet()
)