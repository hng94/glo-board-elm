require('./index.html');
require('./main.scss');
// const uuid = require('short-uuid');

const config = require('./config');
const Elm = require('./Main.elm');
const URL = 'http://localhost:8000/graphql'
const headers =  {
    "content-type": "application/json",
}

const bodyRequest = {
    query: `{
        model {
            tasks {
                id
                name
                columnId
            }
            columns {
                id
                name
                taskInput
            }
            movingTask {
                id
            }
            columnInput
            editCol
            editTask
        }
    }`
}
fetch(URL, {
    method:'POST',
    headers,
    body: JSON.stringify(bodyRequest)
})
.then(res => res.json())
.then(json => {
    let {data:{model}} = json
    console.log(json)
    var app = Elm.Main.fullscreen(model);
    app.ports.sendRequest.subscribe(function(model)  {
        console.log("Dm send request o day", model)
        const {tasks,columns} = model
        const query = `
                mutation UpdateModel($tasks: [InputTask], $columns: [InputColumn]){
                    updateModel(model: {tasks: $tasks, columns: $columns, movingTask: null, columnInput: "", editCol: "", editTask:""}) {
                        tasks {
                            id
                            name
                            columnId
                        }
                        columns {
                            id
                            name
                            taskInput
                        }
                        columnInput
                        movingTask {
                            id
                        }
                        editCol
                        editTask
                    }
                }
            `

        fetch(URL, {
            method: 'POST',
            headers,
            body: JSON.stringify({
                query,
                variables: { 
                    tasks,
                    columns
                 }
            })
        })
        .then(res => res.json())
        .then(json => {
            const {data:{updateModel}} = json
            console.log(updateModel)
            app.ports.receiveData.send(updateModel)
        })
    })

    app.ports.setStorage.subscribe(function(state) {
        fetch(config.URL, {
            method: "PUT",
            headers: {
                "content-type": "application/json",
                "secret-key": config.SECRET
            },
            body: JSON.stringify(state)
        });
    });
});
