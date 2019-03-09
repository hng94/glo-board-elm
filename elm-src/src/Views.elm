module Views exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Models exposing (..)
import EventHelpers exposing (..)

-- CARD VIEW
taskItemView : Model -> Task -> Html Msg
taskItemView model task =
  if model.editTask == task.id then
    div [ class "input-group"]
      [ input [ class "form-control", value task.name, onInput (OnEditTaskInput task.id)] [], 
        div [ class "input-group-append"][
          button  [ class "btn btn-success btn-sm",
                      onClick <| OnClickSaveTask
                  ][
                      text "Save"
                  ]
        ]
      ]
  else
    li [ class "task-item",
        attribute "draggable" "true",
        onDragStart <| Move task,
        onDoubleClick (OnClickEditTask task.id),
        attribute "ondragstart" "event.dataTransfer.setData('text/plain', '')"
      ]
      [ text task.name
      , button [ class "delete-btn remove-btn",
                  onClick <| Delete task.id
                ][]
      ]

-- COLUMN VIEW
editableColHeader : Model -> Column -> Html Msg
editableColHeader model column =
  if model.editCol == column.id then
    div [] [
      input [ class "task-input", value column.name, onInput (OnEditColInput column.id)] [],
      button [ class "btn btn-success btn-sm btn-block", onClick OnClickSaveCol ][ text "Save" ]
    ]
  else 
    div [] [
      h1 [ onDoubleClick (OnClickEditCol column.id) ] [ text column.name ],
      button [ class "btn btn-danger btn-sm btn-block", onClick <| OnClickDeleteCol column ][ text "Delete" ]
    ]

taskColumnView : Model -> List Task -> Column -> Html Msg
taskColumnView model allTasks column =
  let
      tasks = List.filter (\t -> t.columnId == column.id) allTasks
  in
    div [ class "category card-1",
          attribute "ondragover" "return false",
          onDrop <| DropTask column
        ] [
        editableColHeader model column,
        span [] [ text (toString (List.length tasks) ++ " item(s)") ],
        ul [] (List.map (taskItemView model) tasks),
        div [class "task-input-container"] [
          input [ class "task-input", placeholder "New task", value column.taskInput, onInput (TaskInput column)] [],
          button [ class "btn btn-primary btn-sm", onClick <| OnClickAddTask column ] [ text "+" ]
        ]
      ]

