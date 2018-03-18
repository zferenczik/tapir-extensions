/*
 * MIT License
 * 
 * Copyright (c) 2018 Nils Christian Ehmke
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
 package de.rhocas.rapit.datasource.execution.gui.application.views

import de.bmiag.tapir.execution.model.Identifiable
import de.rhocas.rapit.datasource.execution.gui.application.components.ParametersCellValueFactory
import javafx.geometry.Insets
import javafx.scene.control.Button
import javafx.scene.control.CheckBoxTreeItem
import javafx.scene.control.TreeTableColumn
import javafx.scene.control.TreeTableView
import javafx.scene.control.cell.CheckBoxTreeTableCell
import javafx.scene.control.cell.TreeItemPropertyValueFactory
import javafx.scene.layout.HBox
import javafx.scene.layout.Priority
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * The view for the execution plan GUI.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
@Accessors
final class ExecutionPlanView extends VBox {

	val TreeTableView<Identifiable> treeTableView
	ExecutionPlanController executionPlanController

	new() {
		padding = new Insets(10)

		children.add(new HBox() => [
			margin = new Insets(0.0, 0.0, 10, 0.0)
			spacing = 10

			children.add(new Button() => [
				minWidth = 100
				text = 'Select All'
				
				onAction = [executionPlanController.performSelectAll]
			])

			children.add(new Button() => [
				minWidth = 100
				text = 'Deselect All'
				
				onAction = [executionPlanController.performDeselectAll]
			])
			
			children.add(new Button() => [
				minWidth = 100
				text = 'Start Tests'

				HBox.setMargin(it, new Insets(0.0, 0.0, 0.0, 20.0))
				
				onAction = [executionPlanController.performStartTests]
			])
			
			children.add(new Button() => [
				minWidth = 100
				text = 'Cancel'

				onAction = [executionPlanController.performCancel]
			])
		])

		treeTableView = new TreeTableView<Identifiable>() => [
			VBox.setVgrow(it, Priority.ALWAYS)
			
			tableMenuButtonVisible = true
			showRoot = false
			editable = true

			columns.add(new TreeTableColumn<Identifiable, Boolean>() => [
				text = 'Execute'
				
				cellFactory = CheckBoxTreeTableCell.forTreeTableColumn(it)
				cellValueFactory = [cellDataFeature | (cellDataFeature.value as CheckBoxTreeItem<Identifiable>).selectedProperty]
			])

			columns.add(new TreeTableColumn<Identifiable, String>() => [
				text = 'Name'
				
				cellValueFactory = new TreeItemPropertyValueFactory('name')
			])

			columns.add(new TreeTableColumn<Identifiable, String>() => [
				text = 'Description'
				
				cellValueFactory = new TreeItemPropertyValueFactory('description')
			])

			columns.add(new TreeTableColumn<Identifiable, String>() => [
				text = 'Parameters'
				 
				cellValueFactory = new ParametersCellValueFactory()
			])
		]

		// Distribute the columns evenly
		treeTableView.columns.forEach[column|column.prefWidthProperty.bind(treeTableView.widthProperty.divide(treeTableView.columns.size))]

		children.add(treeTableView)
	}

}