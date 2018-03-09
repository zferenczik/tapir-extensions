package de.rhocas.uitestextensions.datasource.excel.annotation

import de.bmiag.tapir.annotationprocessing.annotation.AnnotationProcessor
import de.bmiag.tapir.data.Immutable
import de.rhocas.uitestextensions.datasource.excel.AbstractExcelDataSource
import de.rhocas.uitestextensions.datasource.excel.ExcelRecord
import java.util.Optional
import org.apache.poi.ss.usermodel.Cell
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.core.convert.ConversionService
import org.springframework.stereotype.Component

/**
 * This is the default annotation processor for the {@link ExcelDataSource} annotation. It adds an implementation of {@link AbstractExcelDataSource} and
 * converts an excel row into data container elements.
 * 
 * @see ExcelDataSource
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.0.0
 */ 
@AnnotationProcessor(#[ExcelDataSource])
class ExcelDataSourceProcessor extends AbstractClassProcessor {
	
	override doValidate(ClassDeclaration annotatedClass, extension ValidationContext context) {
		// Make sure that the data container is also annotated with immutable.
		if (!annotatedClass.annotations.exists[annotationTypeDeclaration == Immutable.findTypeGlobally]) {
			val annotation = annotatedClass.annotations.findFirst[annotationTypeDeclaration == ExcelDataSource.findTypeGlobally]
			annotation.addError('''The annotation can only be used in conjunction with «Immutable».''')
		} 
	}
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		// Register the new excel data source class
		annotatedClass.fullQualifiedDataSourceName.registerClass
	}
	 
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val dataSourceClass = annotatedClass.fullQualifiedDataSourceName.findClass
		dataSourceClass.extendedClass = AbstractExcelDataSource.newTypeReference(annotatedClass.newSelfTypeReference)
		
		// Make sure that the data source can be found in the Spring context
		dataSourceClass.addAnnotation(Component.newAnnotationReference)
		
		// The conversion service is injected by Spring and used to map the fields
		dataSourceClass.addField('conversionService') [
			type = ConversionService.newTypeReference()
			addAnnotation(Autowired.newAnnotationReference)
		]
		
		// Now we only have to implement the "mapDataSet" method to map the excel rows to the data type
		dataSourceClass.addMethod('mapDataSet') [
			addAnnotation(Override.newAnnotationReference)
			
			addParameter('excelRecord', ExcelRecord.newTypeReference)
			returnType = annotatedClass.newSelfTypeReference
			
			body = '''
				return «annotatedClass.newSelfTypeReference».build(it -> {
					«Cell» cell;
					«FOR field : annotatedClass.declaredFields»
						«val excelColumn = field.annotations.findFirst[annotationTypeDeclaration == ExcelColumn.findTypeGlobally]»
						«val columnName = if (excelColumn !== null) excelColumn.getStringValue('value') else field.simpleName»
						
						cell = excelRecord.get("«columnName»");
						
						«IF Optional.findTypeGlobally.isAssignableFrom(field.type.type)»
							if (cell != null) {
								final String cellContentString = cell.toString();
								final «field.type.actualTypeArguments.get(0)» cellContent = conversionService.convert(cellContentString, «field.type.actualTypeArguments.get(0)».class);
								
								it.set«field.simpleName.toFirstUpper»(«Optional».of(cellContent));
							} else {
								it.set«field.simpleName.toFirstUpper»(«Optional».empty());
							}
						«ELSE»
							if (cell != null) {
								final String cellContentString = cell.toString();
								final «field.type» cellContent = conversionService.convert(cellContentString, «field.type».class);
								
								it.set«field.simpleName.toFirstUpper»(cellContent);
							}
						«ENDIF»
					«ENDFOR»
				}
				);
			'''
		]
	}
	
	private def String getFullQualifiedDataSourceName(ClassDeclaration annotatedClass) {
		'''«annotatedClass.qualifiedName»ExcelDataSource'''
	}
	
}