package eu.mlich.lucy.dto

import java.util.*

/**
 * @author Juraj Mlich <jurajmlich@gmail.com>
 */
data class FinanceTransactionCategoryDto(
        var id: UUID? = null,
        var name: String,
        var color: String? = null,
        var negative: Boolean,
        var disabled: Boolean
)