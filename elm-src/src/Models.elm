port module Models exposing (..)

type Msg 
  = NoOp 
  | ColumnInput String 
  | TaskInput Column String 
  | Move Task 
  | DropTask Column 
  | OnClickAddTask Column 
  | OnClickAddCol
  | OnClickDeleteCol Column
  | Delete String 
  | ReceivedDataFromJS Model
  | OnClickEditCol String
  | OnEditColInput String String
  | OnClickSaveCol
  | OnClickEditTask String
  | OnEditTaskInput String String
  | OnClickSaveTask

type alias Task = {
    id: String,
    name: String,
    columnId: String
  }

type alias Column = {
  id: String,
  name: String,
  taskInput: String
}

type alias Model = {
  columnInput: String,
  tasks: List Task,
  columns: List Column,
  movingTask: Maybe Task,
  editCol: String,
  editTask: String
}

-- PORTS

port setStorage : Model -> Cmd msg
port sendRequest : Model -> Cmd msg 
port receiveData : (Model -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveData ReceivedDataFromJS

saveData : Model -> ( Model, Cmd Msg )
saveData model = ( model, setStorage model )

-- INITIAL FUNCTION

initModel : Maybe Model -> ( Model, Cmd msg )
initModel model = 
  case model of
    Just model -> ( model, Cmd.none )
    Nothing -> ( Model "" [] [] Nothing "" "", Cmd.none )

-- ADD COLUMN
addNewCol : Model -> (Model, Cmd Msg)
addNewCol model = 
  let 
    newModel = { model | columns = model.columns ++ [Column "0" model.columnInput ""] }
  in
    (model, Cmd.batch [ sendRequest newModel, Cmd.none ])

-- EDIT COLUMN
editColumn : String -> Model -> (Model, Cmd Msg)
editColumn columnId model = 
  let newModel = { model| editCol = columnId }
  in
    (newModel, Cmd.none)

editColumnInput : Model -> String -> String -> (Model, Cmd Msg)
editColumnInput model columnId newColName =
  let
    newColumns = List.map (\col -> 
      if col.id == columnId then
          { col | name = newColName }
      else
          col
        ) model.columns
    newModel = { model| columns = newColumns }
  in
    (newModel, Cmd.none)
-- SAVE COLUMN HEADER
saveColumn : Model  -> (Model, Cmd Msg)
saveColumn model =
  let newModel = { model| editCol = "" }
  in
    (newModel, Cmd.batch [ sendRequest newModel, Cmd.none ])

-- EDIT TASK
editTask : String -> Model -> (Model, Cmd Msg)
editTask taskId model = 
  let newModel = { model| editTask = taskId }
  in
    (newModel, Cmd.none)

editTaskInput : Model -> String -> String -> (Model, Cmd Msg)
editTaskInput model taskId newTaskName =
  let
    newTasks = List.map (\t -> 
      if t.id == taskId then
          { t | name = newTaskName }
      else
          t
        ) model.tasks
    newModel = { model| tasks = newTasks }
  in
    (newModel, Cmd.none)
-- SAVE TASK
saveTask : Model  -> (Model, Cmd Msg)
saveTask model =
  let newModel = { model| editTask = "" }
  in
    (newModel, Cmd.batch [ sendRequest newModel, Cmd.none ])

-- ADD TASK

addNewTask : Column -> Model -> (Model, Cmd Msg)
addNewTask column model =
  let
      newTasks = model.tasks ++ [ Task "0" column.taskInput column.id ]
      newColumns = List.map (\col -> 
        if col.id == column.id then
            { col | taskInput = "" }
        else
            col
          ) model.columns
      newModel = { model | 
                   tasks = newTasks,
                   columns = newColumns
                }
  in
    (model, Cmd.batch [ sendRequest newModel, Cmd.none ])

-- CHANGE TASK STATUS

moveTaskToColumn : Task -> Column -> List Task -> List Task
moveTaskToColumn taskToFind column tasks =
  List.map (\t -> 
    if t.id == taskToFind.id then
       { t | columnId = column.id }
    else
       t
     ) tasks


moveTask : Model -> Column -> (Model, Cmd Msg)
moveTask model column =
  let
      newTasks =
        case model.movingTask of
          Just task -> moveTaskToColumn task column model.tasks
          Nothing -> model.tasks

      newModel = { model | tasks = newTasks, movingTask = Nothing }
  in
      (model, Cmd.batch [ sendRequest newModel, Cmd.none ])

-- DELETE COLUMN
deleteColumn : Model -> String -> (Model, Cmd Msg)
deleteColumn model columnId =
  let
    newModel = { model | columns = List.filter (\x -> x.id /= columnId) model.columns }    
  in
    (model, Cmd.batch [ sendRequest newModel, Cmd.none ])
-- DELETE TASK

deleteTask : Model -> String -> (Model, Cmd Msg)
deleteTask model id =
    let
        newModel = { model | tasks = List.filter (\x -> x.id /= id) model.tasks }
    in
        (model, Cmd.batch [ sendRequest newModel, Cmd.none ])

-- GET TASKS BY STATUS

-- getOnGoingTasks : Model -> List Task
-- getOnGoingTasks model =
--   List.filter (\t -> t.status == "OnGoing") model.tasks

-- getToDoTasks : Model -> List Task
-- getToDoTasks model =
--   List.filter (\t -> t.status == "Todo") model.tasks

-- getDoneTasks : Model -> List Task
-- getDoneTasks model =
--   List.filter (\t -> t.status == "Done") model.tasks


