port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Models exposing (..)
import Views exposing (..)
-- import EventHelpers exposing (..)


main : Program (Maybe Model) Model Msg
main = Html.programWithFlags {
          init = initModel,
          update = update,
          subscriptions = subscriptions,
          view = view
        }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      ( model, Cmd.none )

    -- KeyDown key ->
    --   if key == 13 then
    --      addNewTask model
    --   else
    --     ( model, Cmd.none )
    OnEditColInput columnId newColName -> editColumnInput model columnId newColName

    OnClickSaveCol -> saveColumn model

    OnClickEditCol columnId -> editColumn columnId model

    OnClickAddTask column -> addNewTask column model

    OnClickAddCol -> if model.columnInput /= "" then addNewCol model else (model, Cmd.none)

    OnClickDeleteCol column -> deleteColumn model column.id

    ColumnInput content ->
       ( { model | columnInput = content }, Cmd.none )

    OnEditTaskInput taskId newTaskName -> editTaskInput model taskId newTaskName

    OnClickSaveTask -> saveTask model

    OnClickEditTask taskId -> editTask taskId model

    TaskInput column content -> 
      let
          newColumns = List.map (\col -> 
          if col.id == column.id then
              { col | taskInput = content }
          else
              col
            ) model.columns
      in
        ({model | columns = newColumns}, Cmd.none)

    Move selectedTask ->
      ( { model | movingTask = Just selectedTask }, Cmd.none )

    DropTask column -> moveTask model column

    Delete content -> deleteTask model content

    ReceivedDataFromJS model -> (model, Cmd.none)

renderAddButton : Model -> Html Msg 
renderAddButton model = 
  div [class "category"] [
    input [ placeholder "Add new column", value model.columnInput, onInput ColumnInput ] [],
    button [ onClick OnClickAddCol ] [ text "New" ]
  ]
view : Model -> Html Msg
view model =
  let
      -- todos = getToDoTasks model
      -- ongoing = getOnGoingTasks model
      -- dones = getDoneTasks model
      tasks = model.tasks
  in
      div [ class "board-container light" ] [
        div [ class "kanban-board" ] 
          <| List.concat [
            List.map (taskColumnView model model.tasks) model.columns,
            [
              div [class "category card-1"] [
                input [ class "task-input", placeholder "Add new column", value model.columnInput, onInput ColumnInput ] [],
                button [ class "btn btn-primary btn-sm", onClick OnClickAddCol ] [ text "+" ]
              ]
            ]
          ]
        ] 
