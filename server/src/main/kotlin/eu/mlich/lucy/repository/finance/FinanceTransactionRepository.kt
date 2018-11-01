package eu.mlich.lucy.repository.finance

import eu.mlich.lucy.model.finance.FinanceTransaction
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface FinanceTransactionRepository : JpaRepository<FinanceTransaction, Int> {
    fun findOneByPublicKey(publicKey: UUID): Optional<FinanceTransaction>
}