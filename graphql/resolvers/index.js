const Task = require('../../models/task')
const Column = require('../../models/column')
const mongoose = require('mongoose')
const objectID = require('mongodb').ObjectID

const modelResolver = {
    model: async args => {
        try {
            const tasks  = await Task.find({})
            const columns = await Column.find({})
            const model = {
                tasks,
                columns,
                movingTask: null,
                columnInput: "",
                editCol: "",
                editTask: ""
            }
            return model
        } catch (error) {
            throw error
        }
    },
    updateModel: async args => {
        try {
            const {model} = args
            //Columns
            const validColumns = model.columns.filter(c => objectID.isValid(c.id))
            const columnIds = validColumns.map(c => new objectID(c.id))
            //Update columns
            validColumns.forEach(async c => {
                let column = await Column.findById(new objectID(c.id))
                column.name = c.name
                await column.save()
            });
            //Remove column
            const removeColumn = await Column.findOneAndRemove({
                _id : {
                    $nin : columnIds
                }
            })

            const newCol = model.columns.filter(c => objectID.isValid(c.id) === false)[0]
            if (newCol){
                model.columns = model.columns.filter(c => objectID.isValid(c.id))
                const column = new Column({
                    name: newCol.name,
                    taskInput: ""
                })
                await column.save()        
                model.columns.push(column)
            }

            //Tasks
            const validTasks = model.tasks.filter(t => objectID.isValid(t.id))
            const taskIds = validTasks.map(t => new objectID(t.id))
            //Update tasks
            validTasks.forEach(async t => {
                let task = await Task.findById(new objectID(t.id))
                task.columnId = t.columnId
                task.name = t.name
                await task.save()
            });
            const removeTask = await Task.findOneAndRemove({
                _id : {
                    $nin : taskIds
                }
            })

            const newTask = model.tasks.filter(t => objectID.isValid(t.id) === false)[0]
            if (newTask) {
                model.tasks = model.tasks.filter(t => objectID.isValid(t.id))
                const task = new Task({
                    name: newTask.name,
                    columnId: newTask.columnId
                })
                await task.save()
                model.tasks.push(task)
            }

            return model
        } catch (error) {
            throw error
        }
    }
}

module.exports = modelResolver