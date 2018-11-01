package eu.mlich.lucy.rest

import eu.mlich.lucy.dto.FinanceTransactionCategoryDto
import eu.mlich.lucy.rest.exception.NotFoundException
import eu.mlich.lucy.service.TransactionCategoryService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.domain.Pageable
import org.springframework.web.bind.annotation.*
import java.util.*

@RestController
@RequestMapping(path = ["financeTransactionCategories"])
class FinanceTransactionCategoryResource @Autowired constructor(private val service: TransactionCategoryService) {
    @RequestMapping
    fun findAll(pageRequest: Pageable) = service.findAll(pageRequest)

    @RequestMapping(path = ["ids"])
    fun findIds() = service.findAll().map { it.id }

    @RequestMapping(path = ["{publicKey}"])
    fun findOne(
            @PathVariable("publicKey") publicKey: UUID
    ) = service.findOneByPublicKey(publicKey) ?: throw NotFoundException()

    @RequestMapping(method = [RequestMethod.POST])
    fun create(@RequestBody entity: FinanceTransactionCategoryDto) = service.save(entity)

    @RequestMapping(method = [RequestMethod.PUT], path = ["{publicKey}"])
    fun update(@PathVariable("publicKey") publicKey: UUID, @RequestBody entity: FinanceTransactionCategoryDto): FinanceTransactionCategoryDto {
        entity.id = publicKey
        service.save(entity)
        return entity
    }
}
