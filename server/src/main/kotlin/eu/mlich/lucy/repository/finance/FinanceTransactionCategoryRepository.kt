package eu.mlich.lucy.repository.finance

import eu.mlich.lucy.model.finance.FinanceTransactionCategory
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface FinanceTransactionCategoryRepository : JpaRepository<FinanceTransactionCategory, Int> {
    fun findOneByPublicKey(publicKey: UUID): Optional<FinanceTransactionCategory>
}