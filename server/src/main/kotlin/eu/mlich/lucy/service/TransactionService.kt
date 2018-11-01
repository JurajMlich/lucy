package eu.mlich.lucy.service

import eu.mlich.lucy.dto.FinanceTransactionDto
import eu.mlich.lucy.model.finance.FinanceTransaction
import eu.mlich.lucy.repository.UserRepository
import eu.mlich.lucy.repository.finance.FinanceDepositRepository
import eu.mlich.lucy.repository.finance.FinanceTransactionCategoryRepository
import eu.mlich.lucy.repository.finance.FinanceTransactionRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import java.util.*
import javax.transaction.Transactional

@Service
class TransactionService @Autowired constructor(
        private var repository: FinanceTransactionRepository,
        private var instanceInstructionService: InstanceInstructionService,
        private var userRepository: UserRepository,
        private var financeDepositRepository: FinanceDepositRepository,
        private var financeTransactionCategoryRepository: FinanceTransactionCategoryRepository
) {
    companion object {
        const val RESOURCE_NAME = "transactions"
    }

    fun findAll() = repository.findAll().map { convertToDto(it) }

    fun findAll(pageRequest: Pageable) = repository.findAll(pageRequest).map { convertToDto(it) }

    fun findOneById(id: Int): FinanceTransactionDto? {
        return repository.findById(id)
                .map { convertToDto(it) }
                .orElse(null)
    }

    fun findOneByPublicKey(publicKey: UUID): FinanceTransactionDto? {
        return repository.findOneByPublicKey(publicKey)
                .map { convertToDto(it) }
                .orElse(null)
    }

    @Transactional
    fun save(dto: FinanceTransactionDto): FinanceTransactionDto {
        val entity = repository.save(convertToEntity(dto))
        dto.id = entity.publicKey
        instanceInstructionService.refreshData(RESOURCE_NAME, entity.publicKey.toString())
        return dto
    }

    fun convertToEntity(dto: FinanceTransactionDto): FinanceTransaction { // todo throws
        val creator = userRepository.findOneByPublicKey(dto.creatorId).orElseThrow { IllegalArgumentException() }

        val sourceDepositId = dto.sourceDepositId
        val sourceDeposit = if (sourceDepositId == null) null
        else financeDepositRepository.findOneByPublicKey(sourceDepositId).orElseThrow { IllegalArgumentException() }

        val targetDepositId = dto.targetDepositId
        val targetDeposit = if (targetDepositId == null) null
        else financeDepositRepository.findOneByPublicKey(targetDepositId).orElseThrow { IllegalArgumentException() }
        val categories = dto.categoriesIds.map {
            financeTransactionCategoryRepository.findOneByPublicKey(it).orElseThrow { IllegalArgumentException() }
        }.toHashSet()

        val id = dto.id
        return if (id == null) {
            FinanceTransaction(null, sourceDeposit, targetDeposit, dto.state, dto.value, dto.executionDatetime, creator, dto.name, dto.note, categories)
        } else {
            val original = repository.findOneByPublicKey(id).orElseThrow { IllegalStateException() }
            original.categories = categories
            original.executionDatetime = dto.executionDatetime
            original.name = dto.name
            original.note = dto.note
            original.sourceDeposit = sourceDeposit
            original.targetDeposit = targetDeposit
            original.state = dto.state
            original.value = dto.value
            original
        }
    }

    fun convertToDto(entity: FinanceTransaction): FinanceTransactionDto {
        return FinanceTransactionDto(
                entity.publicKey,
                entity.sourceDeposit?.publicKey,
                entity.targetDeposit?.publicKey,
                entity.state,
                entity.value,
                entity.executionDatetime,
                entity.creator.publicKey,
                entity.name,
                entity.note,
                entity.categories.map { it.publicKey }.toSet()
        )
    }
}