const mongoose = require('mongoose')

const Schema = mongoose.Schema;

const columnSchema = new Schema({
    name: {
        type: String,
        required: true
    },
    taskInput: {
        type: String,
        default: ""
    }
})

module.exports = mongoose.model('Column', columnSchema)