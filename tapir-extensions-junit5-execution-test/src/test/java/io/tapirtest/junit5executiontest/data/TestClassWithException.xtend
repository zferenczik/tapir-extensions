package io.tapirtest.junit5executiontest.data


import de.bmiag.tapir.execution.annotations.step.Step
import de.bmiag.tapir.execution.annotations.testclass.TestClass

@TestClass
class TestClassWithException {

	@Step
	def void step1() {
		assertThat["someString"].withFailMessage("step1 failed").isEmpty
	}

	@Step
	def void step2() {
	}

}
