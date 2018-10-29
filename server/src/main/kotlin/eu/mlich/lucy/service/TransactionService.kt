package eu.mlich.lucy.service

import eu.mlich.lucy.dto.TransactionDto
import eu.mlich.lucy.model.money.Transaction
import eu.mlich.lucy.repository.UserRepository
import eu.mlich.lucy.repository.money.DepositRepository
import eu.mlich.lucy.repository.money.TransactionCategoryRepository
import eu.mlich.lucy.repository.money.TransactionRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import java.util.*
import javax.transaction.Transactional

@Service
class TransactionService @Autowired constructor(
        private var repository: TransactionRepository,
        private var instanceInstructionService: InstanceInstructionService,
        private var userRepository: UserRepository,
        private var depositRepository: DepositRepository,
        private var transactionCategoryRepository: TransactionCategoryRepository
) {
    companion object {
        const val RESOURCE_NAME = "transactions"
    }

    fun findAll() = repository.findAll().map { convertToDto(it) }

    fun findAll(pageRequest: Pageable) = repository.findAll(pageRequest).map { convertToDto(it) }

    fun findOneById(id: Int): TransactionDto? {
        return repository.findById(id)
                .map { convertToDto(it) }
                .orElse(null)
    }

    fun findOneByPublicKey(publicKey: UUID): TransactionDto? {
        return repository.findOneByPublicKey(publicKey)
                .map { convertToDto(it) }
                .orElse(null)
    }

    @Transactional
    fun save(dto: TransactionDto): TransactionDto {
        val entity = repository.save(convertToEntity(dto))
        dto.id = entity.publicKey
        instanceInstructionService.refreshData(RESOURCE_NAME, entity.publicKey.toString())
        return dto
    }

    fun convertToEntity(dto: TransactionDto): Transaction { // todo throws
        val creator = userRepository.findOneByPublicKey(dto.creatorId).orElseThrow { IllegalArgumentException() }

        val sourceDepositId = dto.sourceDepositId
        val sourceDeposit = if (sourceDepositId == null) null
        else depositRepository.findOneByPublicKey(sourceDepositId).orElseThrow { IllegalArgumentException() }

        val targetDeposit = depositRepository.findOneByPublicKey(dto.targetDepositId).orElseThrow { IllegalArgumentException() }
        val categories = dto.categoriesIds.map {
            transactionCategoryRepository.findOneByPublicKey(it).orElseThrow { IllegalArgumentException() }
        }.toHashSet()

        val id = dto.id
        return if (id == null) {
            Transaction(null, sourceDeposit, targetDeposit, dto.state, dto.value, dto.executionDatetime, creator, dto.name, dto.note, categories)
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

    fun convertToDto(entity: Transaction): TransactionDto {
        return TransactionDto(
                entity.publicKey,
                entity.sourceDeposit?.publicKey,
                entity.targetDeposit.publicKey,
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