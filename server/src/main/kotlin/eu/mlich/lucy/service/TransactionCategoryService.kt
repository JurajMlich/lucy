package eu.mlich.lucy.service

import eu.mlich.lucy.dto.FinanceTransactionCategoryDto
import eu.mlich.lucy.model.finance.FinanceTransactionCategory
import eu.mlich.lucy.repository.finance.FinanceTransactionCategoryRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import java.util.*
import javax.transaction.Transactional

@Service
class TransactionCategoryService @Autowired constructor(
        private var repository: FinanceTransactionCategoryRepository,
        private var instanceInstructionService: InstanceInstructionService
) {
    companion object {
        const val RESOURCE_NAME = "transactionCategories"
    }

    fun findAll() = repository.findAll().map { convertToDto(it) }

    fun findAll(pageRequest: Pageable) = repository.findAll(pageRequest).map { convertToDto(it) }

    fun findOneById(id: Int): FinanceTransactionCategoryDto? {
        return repository.findById(id)
                .map { convertToDto(it) }
                .orElse(null)
    }

    fun findOneByPublicKey(publicKey: UUID): FinanceTransactionCategoryDto? {
        return repository.findOneByPublicKey(publicKey)
                .map { convertToDto(it) }
                .orElse(null)
    }

    @Transactional
    fun save(dto: FinanceTransactionCategoryDto): FinanceTransactionCategoryDto {
        val entity = repository.save(convertToEntity(dto))
        dto.id = entity.publicKey
        instanceInstructionService.refreshData(RESOURCE_NAME, entity.publicKey.toString())
        return dto
    }

    fun convertToEntity(dto: FinanceTransactionCategoryDto): FinanceTransactionCategory { // todo throws
        val id = dto.id
        return if (id == null) {
            FinanceTransactionCategory(null, dto.name, dto.color, dto.negative, dto.disabled)
        } else {
            val original = repository.findOneByPublicKey(id).orElseThrow { IllegalStateException() }
            original.color = dto.color
            original.disabled = dto.disabled
            original.name = dto.name
            original.negative = dto.negative
            original
        }
    }

    fun convertToDto(entity: FinanceTransactionCategory): FinanceTransactionCategoryDto {
        return FinanceTransactionCategoryDto(
                entity.publicKey,
                entity.name,
                entity.color,
                entity.negative,
                entity.disabled
        )
    }
}