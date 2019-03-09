const { buildSchema } = require('graphql');

module.exports = buildSchema(`

input InputTask {
    id: String
    name: String
    columnId: String
}

type Task {
    id: String
    name: String!
    columnId: String!
}

input InputColumn {
    id: String
    name: String
    taskInput: String
}

type Column {
    id: String!
    name: String!
    taskInput: String
}

type Model {
  tasks: [Task]!
  columns: [Column]!
  columnInput: String
  movingTask: Task
  editCol: String
  editTask: String
}


input ModelInput {
    tasks: [InputTask]
    columns: [InputColumn]
    columnInput: String
    movingTask: InputTask
    editCol: String
    editTask: String
}


type RootQuery {
    model: Model
}

type RootMutation {
    updateModel(model: ModelInput): Model!
}

schema {
    query: RootQuery
    mutation: RootMutation
}
`);