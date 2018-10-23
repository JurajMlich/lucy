package eu.mlich.lucy.repository

import eu.mlich.lucy.model.Instance
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface InstanceRepository: JpaRepository<Instance, Int>