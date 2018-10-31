package eu.mlich.lucy.service

import eu.mlich.lucy.dto.TransactionCategoryDto
import eu.mlich.lucy.dto.TransactionDto
import eu.mlich.lucy.model.money.Transaction
import eu.mlich.lucy.model.money.TransactionCategory
import eu.mlich.lucy.repository.money.TransactionCategoryRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import java.util.*
import javax.transaction.Transactional

@Service
class TransactionCategoryService @Autowired constructor(
        private var repository: TransactionCategoryRepository,
        private var instanceInstructionService: InstanceInstructionService
) {
    companion object {
        const val RESOURCE_NAME = "transactionCategories"
    }

    fun findAll() = repository.findAll().map { convertToDto(it) }

    fun findAll(pageRequest: Pageable) = repository.findAll(pageRequest).map { convertToDto(it) }

    fun findOneById(id: Int): TransactionCategoryDto? {
        return repository.findById(id)
                .map { convertToDto(it) }
                .orElse(null)
    }

    fun findOneByPublicKey(publicKey: UUID): TransactionCategoryDto? {
        return repository.findOneByPublicKey(publicKey)
                .map { convertToDto(it) }
                .orElse(null)
    }

    @Transactional
    fun save(dto: TransactionCategoryDto): TransactionCategoryDto {
        val entity = repository.save(convertToEntity(dto))
        dto.id = entity.publicKey
        instanceInstructionService.refreshData(RESOURCE_NAME, entity.publicKey.toString())
        return dto
    }

    fun convertToEntity(dto: TransactionCategoryDto): TransactionCategory { // todo throws
        val id = dto.id
        return if (id == null) {
            TransactionCategory(null, dto.name, dto.color, dto.negative, dto.disabled)
        } else {
            val original = repository.findOneByPublicKey(id).orElseThrow { IllegalStateException() }
            original.color = dto.color
            original.disabled = dto.disabled
            original.name = dto.name
            original.negative = dto.negative
            original
        }
    }

    fun convertToDto(entity: TransactionCategory): TransactionCategoryDto {
        return TransactionCategoryDto(
                entity.publicKey,
                entity.name,
                entity.color,
                entity.negative,
                entity.disabled
        )
    }
}