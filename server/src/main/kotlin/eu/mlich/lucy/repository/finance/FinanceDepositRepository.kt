package eu.mlich.lucy.repository.finance

import eu.mlich.lucy.model.finance.FinanceDeposit
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface FinanceDepositRepository: JpaRepository<FinanceDeposit, Int> {
    fun findOneByPublicKey(publicKey: UUID): Optional<FinanceDeposit>
}