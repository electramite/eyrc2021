defmodule CLI.ToyRobotB do
  # max x-coordinate of table top
  @table_top_x 5
  # max y-coordinate of table top
  @table_top_y :e
  # mapping of y-coordinates
  @robot_map_y_atom_to_num %{:a => 1, :b => 2, :c => 3, :d => 4, :e => 5}
  @robot_facing_to_num %{:east => 1, :south => 2, :west => 3, :north => 4}

  @doc """
  Places the robot to the default position of (1, A, North)

  Examples:

      iex> CLI.ToyRobotB.place
      {:ok, %CLI.Position{facing: :north, x: 1, y: :a}}
  """
  def place do
    {:ok, %CLI.Position{}}
  end

  def place(x, y, _facing) when x < 1 or y < :a or x > @table_top_x or y > @table_top_y do
    {:failure, "Invalid position"}
  end

  def place(_x, _y, facing)
  when facing not in [:north, :east, :south, :west]
  do
    {:failure, "Invalid facing direction"}
  end

  @doc """
  Places the robot to the provided position of (x, y, facing),
  but prevents it to be placed outside of the table and facing invalid direction.

  Examples:

      iex> CLI.ToyRobotB.place(1, :b, :south)
      {:ok, %CLI.Position{facing: :south, x: 1, y: :b}}

      iex> CLI.ToyRobotB.place(-1, :f, :north)
      {:failure, "Invalid position"}

      iex> CLI.ToyRobotB.place(3, :c, :north_east)
      {:failure, "Invalid facing direction"}
  """
  def place(x, y, facing) do
    # IO.puts String.upcase("B I'm placed at => #{x},#{y},#{facing}")
    {:ok, %CLI.Position{x: x, y: y, facing: facing}}
  end

  @doc """
  Provide START position to the robot as given location of (x, y, facing) and place it.
  """
  def start(x, y, facing) do
    ###########################
    ## complete this funcion ##
    ###########################
    place(x, y, facing)
  end

  ############################### 1B #####################################################
  def mod(num) do
    if num < 0 do
      num = - num
    else
      num
    end
  end
  ## this function checks only right recursively
  def right_check(robot, id) do
    robot = right(robot)
    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
    Process.register(pid, :client_toyrobotB)
    val = obstacle()
    cond do
      val == :false ->
        ## if no obstacle present
        robot = move(robot)
        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
        Process.register(pid, :client_toyrobotB)
        obstacle()
        #{robot, id}
        {:ok, robot}
      val == :true ->
        ## if obstacle is present
        robot = left(robot)
        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
        Process.register(pid, :client_toyrobotB)
        obstacle()
        robot = move(robot)
        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
        Process.register(pid, :client_toyrobotB)
        obstacle()
        right_check(robot, id)
    end
  end

## this function checks only left recursively
  def left_check(robot, id) do
    robot = left(robot)
    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
    Process.register(pid, :client_toyrobotB)
    val = obstacle()
    cond do
      val == :false ->
        ## if no obstacle present
        robot = move(robot)
        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
        Process.register(pid, :client_toyrobotB)
        obstacle()
        {:ok, robot}
      val == :true ->
        ## if obstacle is present
        robot = right(robot)
        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
        Process.register(pid, :client_toyrobotB)
        obstacle()
        cond do
          robot.y == :a and robot.facing == :south ->
            robot = right(robot)
            pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
            Process.register(pid, :client_toyrobotB)
            obstacle()
            robot = right(robot)
            pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
            Process.register(pid, :client_toyrobotB)
            obstacle()
            {:ok, robot} = right_check(robot, id)
            {:ok, robot}
          robot.y == :e and robot.facing == :north ->
            robot = left(robot)
            pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
            Process.register(pid, :client_toyrobotB)
            obstacle()
            robot = left(robot)
            pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
            Process.register(pid, :client_toyrobotB)
            obstacle()
            {:ok, robot} = right_check(robot, id)
            {:ok, robot}
          robot.x == 1 and robot.facing == :west ->
            robot = left(robot)
            pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
            Process.register(pid, :client_toyrobotB)
            obstacle()
            robot = left(robot)
            pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
            Process.register(pid, :client_toyrobotB)
            obstacle()
            {:ok, robot} = right_check(robot, id)
            {:ok, robot}

          robot.x == 5 and robot.facing == :east ->
            robot = left(robot)
            pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
            Process.register(pid, :client_toyrobotB)
            obstacle()
            robot = left(robot)
            pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
            Process.register(pid, :client_toyrobotB)
            obstacle()
            {:ok, robot} = right_check(robot, id)
            {:ok, robot}
          :true ->
            robot = move(robot)
            pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
            Process.register(pid, :client_toyrobotB)
            obstacle()
            left_check(robot, id)
        end
    end
  end
## this function checks right and left both recursively
def right_left_check(first, robot, id) do
  cond do
    first == :right ->
      robot = right(robot)
      pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
      Process.register(pid, :client_toyrobotB)
      val = obstacle()
      cond do
        val == :false ->
          ## if no obstacle at right
          {:ok, robot}
        val == :true ->
          ## if obstacle is present at right, check left
          robot = left(robot)
          pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
          Process.register(pid, :client_toyrobotB)
          obstacle()
          robot = left(robot)
          pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
          Process.register(pid, :client_toyrobotB)
          val = obstacle()
          cond do
            val == :false ->
              ## if no obstacle at left
              {:ok, robot}
            val == :true ->
              ## if obstacle present at left
              robot = right(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              obstacle()
              robot = move(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              obstacle()
              right_left_check(:right, robot, id)
          end
      end
    first == :left ->
      robot = left(robot)
      pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
      Process.register(pid, :client_toyrobotB)
      val = obstacle()
      cond do
        val == :false ->
          ## if no obstacle at left
          {:ok, robot}
        val == :true ->
          ## if obstacle is present at left, check right
          robot = right(robot)
          pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
          Process.register(pid, :client_toyrobotB)
          obstacle()
          robot = right(robot)
          pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
          Process.register(pid, :client_toyrobotB)
          val = obstacle()
          cond do
            val == :false ->
              ## if no obstacle at right
              {:ok, robot}
            val == :true ->
              ## if obstacle present at right
              robot = left(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              cond do
                val == :false ->
                  # no obstacle ahead
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  right_left_check(:left, robot, id)
                val == :true ->
                  #if obstacle ahead
                  # still left to consider.
              end

          end
      end
    end
end



  def way_to_go(goal_x, goal_y, robot, id) do
    #############################
    #### mooving along X axix####
    #############################
    cond do
      robot.facing == :east ->
        cond do
          @robot_map_y_atom_to_num[robot.y] < @robot_map_y_atom_to_num[goal_y] ->
              ## goal is located above
              robot = left(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              if val == :true do
                ## if obstacle is present at left take u turn (west)
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                obstacle()
                cond do
                robot.y == :a ->
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = right_check(robot, id)
                  {:ok, robot}  ## note: axix change
                :true ->
                  robot = left(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  val = obstacle()
                  cond do
                    val == :false ->
                      ## if obstacle is not present
                      robot = move(robot)
                      pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                      Process.register(pid, :client_toyrobotB)
                      obstacle()
                      {:ok, robot}
                    val == :true ->
                      ## if obstacle is present, take u turn
                      robot = right(robot)
                      pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                      Process.register(pid, :client_toyrobotB)
                      obstacle()
                      robot = move(robot)
                      pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                      Process.register(pid, :client_toyrobotB)
                      obstacle()
                      {:ok, robot} = right_left_check(:right, robot, id)
                      {:ok, robot}
                  end
                end
              else
                {:ok, robot}
              end
          @robot_map_y_atom_to_num[robot.y] > @robot_map_y_atom_to_num[goal_y] -> # goal is located below
              # turn right
              robot = right(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              if val == :true do
                robot = right(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                obstacle()
                cond do
                  robot.y == :e ->
                    robot = move(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    {:ok, robot} = left_check(robot, id)
                    {:ok, robot}  ## note: axix change
                  :true ->
                    robot = right(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    val = obstacle()
                    cond do
                      val == :false ->
                        ## if obstacle is not present
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot}
                      val == :true ->
                        ## if obstacle is present, take u turn
                        robot = left(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = right_left_check(:left, robot, id)
                        {:ok, robot}
                    end
                  end
              else
                {:ok, robot}
              end
          robot.y == goal_y -> ## goal is located on the same line
            cond do
              robot.y == :a ->
              ## check only left
              robot = left(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              cond do
                val == :false ->
                  ## if no obstacle at left, move one block forward
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = right_check(robot, id)
                  {:ok, robot} = stop_xy(goal_x, goal_y, robot, id)
                  {:ok, robot}
                val == :true ->
                  ## if obstacle is present at left, take u turn and chaeck right
                  robot = left(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = right_check(robot, id)
                  {:ok, robot} = stop_xy(goal_x, goal_y, robot, id)
                  {:ok, robot}
              end
              robot.y == :e ->
              ## check only right
              robot = right(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              cond do
                val == :false ->
                  ## if no obstacle at right, move one block forward
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = left_check(robot, id)
                  {:ok, robot} = stop_xy(goal_x, goal_y, robot, id)
                  {:ok, robot}
                val == :true ->
                  ## if obstacle is present at right, take u turn and chaeck right
                  robot = right(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = left_check(robot, id)
                  {:ok, robot} = stop_xy(goal_x, goal_y, robot, id)
                  {:ok, robot}
              end
              :true ->
                ## check right and left both
                robot = right(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                val = obstacle()
                cond do
                  val == :false ->
                    ## if no obstacle is present
                    robot = move(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    {:ok, robot} = left_check(robot, id)
                    {:ok, robot} = stop_xy(goal_x, goal_y, robot, id)
                    {:ok, robot}
                  val == :true ->
                    ## if obstacle is present
                    robot = left(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    robot = left(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    val = obstacle()
                    cond do
                      val == :false ->
                        ## no obstacle at left
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = right_check(robot, id)
                        {:ok, robot} = stop_xy(goal_x, goal_y, robot, id)
                        {:ok, robot}
                      val == :true ->
                        ## if obstacle is present at left side, take u turn move oon block
                        robot = left(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = right_left_check(:left, robot, id)
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = stop_xy(goal_x, goal_y, robot, id)
                        {:ok, robot}
                    end
                end
            end
        end
      robot.facing == :west ->
        cond do
          @robot_map_y_atom_to_num[robot.y] < @robot_map_y_atom_to_num[goal_y] -> # goal is located above
              robot = right(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              if val == :true do # u turn if obstacle is present
                robot = right(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                obstacle()
                cond do
                  robot.y == :a ->
                    robot = move(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    {:ok, robot} = left_check(robot, id)
                    {:ok, robot}  ## note: axix change
                  :true ->
                    robot = right(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    val = obstacle()
                    cond do
                      val == :false ->
                        ## if obstacle is not present
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot}
                      val == :true ->
                        ## if obstacle is present, take u turn
                        robot = left(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = right_left_check(:left, robot, id)
                        {:ok, robot}
                    end
                  end
              else
                {:ok, robot}
              end
          @robot_map_y_atom_to_num[robot.y] > @robot_map_y_atom_to_num[goal_y] -> # goal is located below
              robot = left(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              if val == :true do # u turn if obstacle is present
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                obstacle()
                cond do
                  robot.y == :e ->
                    robot = move(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    {:ok, robot} = right_check(robot, id)
                    {:ok, robot}  ## note: axix change
                  :true ->
                    robot = left(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    val = obstacle()
                    cond do
                      val == :false ->
                        ## if obstacle is not present
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot}
                      val == :true ->
                        ## if obstacle is present, take u turn
                        robot = right(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = right_left_check(:right, robot, id)
                        {:ok, robot}
                    end
                  end
              else
                {:ok, robot}
              end
          robot.y == goal_y -> ## if goal is loacted on the same axis when approaching from west
            cond do
              robot.y == :e ->
              ## check only left
              robot = left(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              cond do
                val == :false ->
                  ## if no obstacle at left, move one block forward
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = right_check(robot, id)
                  {:ok, robot} = stop_xy(goal_x, goal_y, robot, id)
                  {:ok, robot}
                val == :true ->
                  ## if obstacle is present at left, take u turn and chaeck right
                  robot = left(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = right_check(robot, id)
                  {:ok, robot}
              end
              robot.y == :a ->
              ## check only right
              robot = right(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              cond do
                val == :false ->
                  ## if no obstacle at right, move one block forward
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = left_check(robot, id)
                  {:ok, robot}
                val == :true ->
                  ## if obstacle is present at right, take u turn and chaeck right
                  robot = right(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = left_check(robot, id)
                  {:ok, robot}
              end
              :true ->
                ## check right and left both
                robot = right(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                val = obstacle()
                cond do
                  val == :false ->
                    ## if no obstacle is present
                    robot = move(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    {:ok, robot} = left_check(robot, id)
                    {:ok, robot}
                  val == :true ->
                    ## if obstacle is present
                    robot = left(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    robot = left(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    val = obstacle()
                    cond do
                      val == :false ->
                        ## no obstacle at left
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot}
                      val == :true ->
                        ## if obstacle is present at left side, take u turn move oon block
                        robot = left(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = right_left_check(:right, robot, id)
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot}
                    end
                end
            end
        end
      #############################
      #### mooving along Y axix####
      #############################
      robot.facing == :north ->
        cond do
          robot.x > goal_x -> # goal is located left
              # turn left
              robot = left(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              if val == :true do
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                obstacle()
                cond do
                  robot.x == 5 ->
                    robot = move(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    {:ok, robot} = right_check(robot, id)
                    {:ok, robot}  ## note: axix change
                  :true ->
                    robot = left(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    val = obstacle()
                    cond do
                      val == :false ->
                        ## if obstacle is not present
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot}
                      val == :true ->
                        ## if obstacle is present, take u turn
                        robot = right(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = right_left_check(:right, robot, id)
                        {:ok, robot}
                    end
                  end
              else
                {:ok, robot}
              end
          robot.x < goal_x -> # goal is located right
              # turn right
              robot = right(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              if val == :true do
                robot = right(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                obstacle()
                cond do
                  robot.x == 1 ->
                    robot = move(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    {:ok, robot} = left_check(robot, id)
                    {:ok, robot}  ## note: axix change
                  :true ->
                    robot = right(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    val = obstacle()
                    cond do
                      val == :false ->
                        ## if obstacle is not present
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot}
                      val == :true ->
                        ## if obstacle is present, take u turn
                        robot = left(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = right_left_check(:left, robot, id)
                        {:ok, robot}
                    end
                  end
              else
                {:ok, robot}
              end
          robot.x == goal_x -> # goal is located on the same line
            cond do
              robot.x == 1 ->
              ## check only right
              robot = right(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              cond do
                val == :false ->
                  ## if no obstacle at right, move one block forward
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  #{:ok, robot} = left_check(robot, id)
                  {:ok, robot} = right_left_check(:left, robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}
                val == :true ->
                  ## if obstacle is present at right, take u turn and chaeck right
                  robot = right(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = left_check(robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}
              end
              robot.x == 5 ->
              ## check only left
              robot = left(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              cond do
                val == :false ->
                  ## if no obstacle at left, move one block forward
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = right_check(robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}
                val == :true ->
                  ## if obstacle is present at left, take u turn and chaeck right
                  robot = left(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = right_check(robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}
              end
              :true ->
                ## check right and left both
                robot = right(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                val = obstacle()
                cond do
                  val == :false ->
                    ## if no obstacle is present
                    robot = move(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag)end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    {:ok, robot} = left_check(robot, id)
                    {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                    {:ok, robot}
                  val == :true ->
                    ## if obstacle is present
                    robot = left(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    robot = left(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    val = obstacle()
                    cond do
                      val == :false ->
                        ## no obstacle at left
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = right_check(robot, id)
                        {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                        {:ok, robot}
                      val == :true ->
                        ## if obstacle is present at left side, take u turn move one block
                        robot = left(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = right_left_check(:right, robot, id)
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                        {:ok, robot}
                    end
                end
            end
        end
      robot.facing == :south ->
        cond do
          robot.x > goal_x -> # goal is located right
              robot = right(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              if val == :true do
                robot = right(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                obstacle()
                cond do
                  robot.x == 5 ->
                    robot = move(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    {:ok, robot} = left_check(robot, id)
                    {:ok, robot}  ## note: axix change
                  :true ->
                    robot = right(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    val = obstacle()
                    cond do
                      val == :false ->
                        ## if obstacle is not present
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot}
                      val == :true ->
                        ## if obstacle is present, take u turn
                        robot = left(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = right_left_check(:right, robot, id)
                        {:ok, robot}
                    end
                  end
              else
                {:ok, robot}
              end
          robot.x < goal_x -> # goal is located left
              robot = left(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              if val == :true do
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                obstacle()
                cond do
                  robot.x == 1 ->
                    robot = move(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    {:ok, robot} = right_check(robot, id)
                    {:ok, robot}  ## note: axix change
                  :true ->
                    robot = left(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    val = obstacle()
                    cond do
                      val == :false ->
                        ## if obstacle is not present
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot}
                      val == :true ->
                        ## if obstacle is present, take u turn
                        robot = right(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = right_left_check(:right, robot, id)
                        {:ok, robot}
                    end
                  end
              else
                {:ok, robot}
              end
          robot.x == goal_x ->
            cond do
              robot.x == 1 ->
              ## check only left
              robot = left(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              cond do
                val == :false ->
                  ## if no obstacle at left, move one block forward
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = right_check(robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}
                val == :true ->
                  ## if obstacle is present at left, take u turn and chaeck right
                  robot = right(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = left_check(robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}
              end
              robot.x == 5 ->
              ## check only right
              robot = right(robot)
              pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
              Process.register(pid, :client_toyrobotB)
              val = obstacle()
              cond do
                val == :false ->
                  ## if no obstacle at right, move one block forward
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = left_check(robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}
                val == :true ->
                  ## if obstacle is present at right, take u turn and chaeck right
                  robot = left(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  robot = move(robot)
                  pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                  Process.register(pid, :client_toyrobotB)
                  obstacle()
                  {:ok, robot} = right_check(robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}
              end
              :true ->
                ## check right and left both
                robot = right(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                val = obstacle()
                cond do
                  val == :false ->
                    ## if no obstacle is present
                    robot = move(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    {:ok, robot} = left_check(robot, id)
                    {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                    {:ok, robot}
                  val == :true ->
                    ## if obstacle is present
                    robot = left(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    obstacle()
                    robot = left(robot)
                    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                    Process.register(pid, :client_toyrobotB)
                    val = obstacle()
                    cond do
                      val == :false ->
                        ## no obstacle at left
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                        {:ok, robot}
                      val == :true ->
                        ## if obstacle is present at left side, take u turn move oon block
                        robot = left(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = right_left_check(:left, robot, id)
                        robot = move(robot)
                        pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                        Process.register(pid, :client_toyrobotB)
                        obstacle()
                        {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                        {:ok, robot}
                    end
                end
            end
        end
    end
  end

  def move_along_xy(goal_x, goal_y, robot, id) do
    del_x = mod(goal_x - robot.x)
    del_y = mod(@robot_map_y_atom_to_num[goal_y] - @robot_map_y_atom_to_num[robot.y])
    cond do
      robot.facing == :east or robot.facing == :west ->
          robot = move(robot)
          pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
          Process.register(pid, :client_toyrobotB)
          val = obstacle()
          if del_x-1 > 0 do
            cond do
            val == :false ->
              move_along_xy(goal_x, goal_y, robot, id) # if no obstacle is present, move
            val == :true ->
              {:ok, robot} = way_to_go(goal_x, goal_y, robot, id)
              {:ok, robot}
            end
          else
            {:ok, robot}
          end
      robot.facing == :north or robot.facing == :south ->
          robot = move(robot)
          pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
          Process.register(pid, :client_toyrobotB)
          val = obstacle()
          if del_y-1 > 0 do
            cond do
            val == :false ->
              move_along_xy(goal_x, goal_y, robot, id) # if no obstacle is present, move
            val == :true ->
              {:ok, robot} = way_to_go(goal_x, goal_y, robot, id)
              {:ok, robot}
            end
          else
            {:ok, robot}
          end
    end
  end

  ######################## 1 A #####################################################################
  def obstacle() do
    val = receive do
      value -> value
    end
    val
  end

  def stop_y(goal_x, goal_y, robot, id) do
    facing_2_the_right = %{north: :east, east: :south, south: :west, west: :north}
    right_facing = facing_2_the_right[robot.facing]
    #IO.puts(@robot_map_y_atom_to_num[robot.y])
    #IO.puts(@robot_map_y_atom_to_num[goal_y])
    del_y = @robot_map_y_atom_to_num[goal_y] - @robot_map_y_atom_to_num[robot.y]
    #del_y = 4

    cond do
      del_y > 0 ->
        del_d = @robot_facing_to_num[robot.facing] - @robot_facing_to_num[:north]
        del_d = mod(del_d)
        # turn north
        cond do
          right_facing == :north ->
            robot = right(robot)
            pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
            Process.register(pid, :client_toyrobotB)
            val = obstacle()
            if val == :true do # if obstacle at north
              ## still left to consider
              cond do
                robot.x == 5 ->
                  #{robot, id} = left_check(robot, id)
                  {:ok, robot} = left_check(robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}
                robot.x == 1 ->
                  #{robot, id} = right_check(robot, id)
                  {:ok, robot} = right_check(robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}
              end
            else
              {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
              {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
              {:ok, robot}  # changed
            end
          right_facing != :north ->
            cond do
              del_d == 2 ->
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                obstacle()
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                val = obstacle()
                if val == :true do # if obstacle at north
                ## still left to consider
                cond do
                  robot.x == 5 ->
                    #{robot, id} = left_check(robot, id)
                    {:ok, robot} = left_check(robot, id)
                    {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                    {:ok, robot}
                  robot.x == 1 ->
                    #{robot, id} = right_check(robot, id)
                    {:ok, robot} = right_check(robot, id)
                    {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                    {:ok, robot}
                end
                else
                  {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}  # changed
                end
              del_d == 1 or del_d == 3 ->
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                val = obstacle()
                if val == :true do # if obstacle at north
                cond do
                  robot.x == 5 ->
                    #{robot, id} = left_check(robot, id)
                    {:ok, robot} = left_check(robot, id)
                    {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                    {:ok, robot}
                  robot.x == 1 ->
                    #{robot, id} = right_check(robot, id)
                    {:ok, robot} = right_check(robot, id)
                    {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                    {:ok, robot}
                end

                else
                  {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}  # changed
                end
              del_d == 0 ->
                {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
                {:ok, robot}
            end
        end
      del_y < 0 ->
        # turn south
        del_d = @robot_facing_to_num[robot.facing] - @robot_facing_to_num[:south]
        del_d = mod(del_d)
        cond do
          right_facing == :south ->
            robot = right(robot)
            pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
            Process.register(pid, :client_toyrobotB)
            val = obstacle()
            if val == :true do # if obstacle at north
              ## still left to consider
              cond do
                robot.x == 1 ->
                  #{robot, id} = left_check(robot, id)
                  {:ok, robot} = left_check(robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}
                robot.x == 5 ->
                  #{robot, id} = right_check(robot, id)
                  {:ok, robot} = right_check(robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}
              end
            else
              {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
              {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
              {:ok, robot}  # changed
            end
          right_facing != :south ->
            cond do
              del_d == 2 ->
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                obstacle()
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                val = obstacle()
                if val == :true do # if obstacle at north
                ## still left to consider
                cond do
                  robot.x == 1 ->
                    #{robot, id} = left_check(robot, id)
                    {:ok, robot} = left_check(robot, id)
                    {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                    {:ok, robot}
                  robot.x == 5 ->
                    #{robot, id} = right_check(robot, id)
                    {:ok, robot} = right_check(robot, id)
                    {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                    {:ok, robot}
                end
                else
                  {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}  # changed
                end
              del_d == 1 or del_d == 3 ->
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                val = obstacle()
                if val == :true do # if obstacle at north
                ## still left to consider
                cond do
                  robot.x == 1 ->
                    #{robot, id} = left_check(robot, id)
                    {:ok, robot} = left_check(robot, id)
                    {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                    {:ok, robot}
                  robot.x == 5 ->
                    #{robot, id} = right_check(robot, id)
                    {:ok, robot} = right_check(robot, id)
                    {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                    {:ok, robot}
                end
                else
                  {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
                  {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
                  {:ok, robot}  # changed
                end
              del_d == 0 ->
                {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
                {:ok, robot}
            end
        end
      del_y == 0 ->
        {:ok, robot} = stop_x(goal_x, goal_y, robot, id)
        {:ok, robot}
    end
  end

  def stop_x(goal_x, goal_y, robot, id) do
    facing_2_the_right = %{north: :east, east: :south, south: :west, west: :north}
    right_facing = facing_2_the_right[robot.facing]
    del_x = goal_x - robot.x
    del_y = @robot_map_y_atom_to_num[goal_y] - @robot_map_y_atom_to_num[robot.y]
    cond do
      del_x > 0 ->
        # turn east
        del_d = @robot_facing_to_num[robot.facing] - @robot_facing_to_num[:east]
        del_d = mod(del_d)
        cond do
          right_facing == :east ->
            robot = right(robot)
            pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
            Process.register(pid, :client_toyrobotB)
            val = obstacle()
            if val == :true do # if obstacle at east
              ## still left to consider
              cond do
                robot.x == 1 ->
                  cond do
                    robot.y == :e ->
                      {robot, id} = right_check(robot, id)
                      {robot, id}
                    robot.y == :a ->
                      {robot, id} = left_check(robot, id)
                      {robot, id}
                  end
              end
            else
              {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
              {:ok, robot}
            end
          right_facing != :east ->
            cond do
              del_d == 2 ->
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                obstacle()
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                val = obstacle()
                if val == :true do # if obstacle at east
                ## still left to consider
                cond do
                  robot.x == 1 ->
                    cond do
                      robot.y == :e ->
                        {robot, id} = right_check(robot, id)
                        {robot, id}
                      robot.y == :a ->
                        {robot, id} = left_check(robot, id)
                        {robot, id}
                    end
                end
                else
                  {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
                  {:ok, robot}
                end
              del_d == 1 or del_d == 3 ->
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                val = obstacle()
                if val == :true do # if obstacle at north
                ## still left to consider
                cond do
                  robot.x == 1 ->
                    cond do
                      robot.y == :e ->
                        {robot, id} = right_check(robot, id)
                        {robot, id}
                      robot.y == :a ->
                        {robot, id} = left_check(robot, id)
                        {robot, id}
                    end
                end

                else
                  {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
                  {:ok, robot}
                end
              del_d == 0 ->
                {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
                {:ok, robot}
            end
        end
      del_x < 0 ->
        # turn west
        del_d = @robot_facing_to_num[robot.facing] - @robot_facing_to_num[:west]
        del_d = mod(del_d)
        cond do
          right_facing == :west ->
            robot = right(robot)
            pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
            Process.register(pid, :client_toyrobotB)
            val = obstacle()
            if val == :true do # if obstacle at west
              ## still left to consider
              cond do
                robot.x == 5 ->
                  cond do
                    robot.y == :a ->
                      {robot, id} = right_check(robot, id)
                      {robot, id}
                    robot.y == :e ->
                      {robot, id} = left_check(robot, id)
                      {robot, id}
                  end
              end
            else
              {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
              {:ok, robot}
            end
          right_facing != :west ->
            cond do
              del_d == 2 ->
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                obstacle()
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                val = obstacle()
                if val == :true do # if obstacle at north
                ## still left to consider
                cond do
                  robot.x == 5 ->
                    cond do
                      robot.y == :a ->
                        {robot, id} = right_check(robot, id)
                        {robot, id}
                      robot.y == :e ->
                        {robot, id} = left_check(robot, id)
                        {robot, id}
                    end
                end

                else
                  {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
                  {:ok, robot}
                end
              del_d == 1 or del_d == 3 ->
                robot = left(robot)
                pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
                Process.register(pid, :client_toyrobotB)
                val = obstacle()
                if val == :true do # if obstacle at north
                ## still left to consider
                cond do
                  robot.x == 5 ->
                    cond do
                      robot.y == :a ->
                        {robot, id} = right_check(robot, id)
                        {robot, id}
                      robot.y == :e ->
                        {robot, id} = left_check(robot, id)
                        {robot, id}
                    end
                end
                else
                  {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
                  {:ok, robot}
                end
              del_d == 0 ->
                {:ok, robot} = move_along_xy(goal_x, goal_y, robot, id)
                {:ok, robot}
            end
        end
      del_x == 0 ->
        {:ok, robot} = stop_y(goal_x, goal_y, robot, id)
        {:ok, robot}
    end
  end
  def stop_yx(goal_x, goal_y, robot, id) do
    {:ok, robot} = stop_y(goal_x, goal_y, robot, id)
    cond do
      robot.y == goal_y ->
        # y destination reached
        if robot.x == goal_x do
          {:ok, robot} ## if no displacment required for x
        else
          {:ok, robot} = stop_x(goal_x, goal_y, robot, id)
          cond do
            # reached x
            robot.x == goal_x ->
              {:ok, robot}
            # not reach x
            robot.x != goal_x ->
              {:ok, robot} = stop_xy(goal_x, goal_y, robot, id)
              {:ok, robot}
          end
        end
      # y destination not reached
      robot.y != goal_y ->
        {:ok, robot} = way_to_go(goal_x, goal_y, robot, id)
        {:ok, robot} = stop_xy(goal_x, goal_y, robot, id)
        {:ok, robot}
      :true ->
        {:ok, robot}
    end
  end

  def stop_xy(goal_x, goal_y, robot, id) do
    {:ok, robot} = stop_x(goal_x, goal_y, robot, id)
    cond do
      robot.x == goal_x ->
        # x destination reached
        if robot.y == goal_y do
          {:ok, robot}
        else
          {:ok, robot} = stop_y(goal_x, goal_y, robot, id)
          cond do
            # reached y
            robot.y == goal_y -> {:ok, robot}
            # not reach x
            robot.y != goal_y ->
              {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
              {:ok, robot}
          end
        end
      # x destination not reached
      robot.x != goal_x ->
        {:ok, robot} = way_to_go(goal_x, goal_y, robot, id)
        {:ok, robot} = stop_yx(goal_x, goal_y, robot, id)
        {:ok, robot}
    end
  end

  def stop(_robot, goal_x, goal_y, _cli_proc_name) when goal_x < 1 or goal_y < :a or goal_x > @table_top_x or goal_y > @table_top_y do
    {:failure, "Invalid STOP position"}

  end

  @doc """
  Provide GOAL positions to the robot as given location of [(x1, y1),(x2, y2),..] and plan the path from START to these locations.
  Passing the CLI Server process name that will be used to send robot's current status after each action is taken.
  Spawn a process and register it with name ':client_toyrobotBB' which is used by CLI Server to send an
  indication for the presence of obstacle ahead of robot's current position and facing.
  """
  def stop(robot, goal_locs, cli_proc_name) do
    ###########################
    ## complete this funcion ##
    ###########################
    #IO.puts(Kernel.length(goal_locs))
    [goal_x, goal_y] = List.last(goal_locs)
    goal_x = String.to_integer(goal_x)
    goal_y = String.to_atom(goal_y)
    id = self()
    pid = spawn_link(fn -> flag = send_robot_status(robot, :cli_robot_state); send(id, flag) end)
    Process.register(pid, :client_toyrobotB)
    val = obstacle()
    if val == :true do
      {:ok, robot} = way_to_go(goal_x, goal_y, robot, id)
      stop_yx(goal_x, goal_y, robot, id)
    else
      stop_yx(goal_x, goal_y, robot, id)
    end

  end

  @doc """
  Send Toy Robot's current status i.e. location (x, y) and facing
  to the CLI Server process after each action is taken.
  Listen to the CLI Server and wait for the message indicating the presence of obstacle.
  The message with the format: '{:obstacle_presence, < true or false >}'.
  """
  def send_robot_status(%CLI.Position{x: x, y: y, facing: facing} = _robot, cli_proc_name) do
    send(cli_proc_name, {:toyrobotB_status, x, y, facing})
    # IO.puts("Sent by Toy Robot Client: #{x}, #{y}, #{facing}")
    listen_from_server()
  end

  @doc """
  Listen to the CLI Server and wait for the message indicating the presence of obstacle.
  The message with the format: '{:obstacle_presence, < true or false >}'.
  """
  def listen_from_server() do
    receive do
      {:obstacle_presence, is_obs_ahead} ->
        is_obs_ahead
    end
  end

  @doc """
  Provides the report of the robot's current position

  Examples:

      iex> {:ok, robot} = CLI.ToyRobotB.place(2, :b, :west)
      iex> CLI.ToyRobotB.report(robot)
      {2, :b, :west}
  """
  def report(%CLI.Position{x: x, y: y, facing: facing} = _robot) do
    {x, y, facing}
  end

  @directions_to_the_right %{north: :east, east: :south, south: :west, west: :north}
  @doc """
  Rotates the robot to the right
  """
  def right(%CLI.Position{facing: facing} = robot) do
    %CLI.Position{robot | facing: @directions_to_the_right[facing]}
  end

  @directions_to_the_left Enum.map(@directions_to_the_right, fn {from, to} -> {to, from} end)
  @doc """
  Rotates the robot to the left
  """
  def left(%CLI.Position{facing: facing} = robot) do
    %CLI.Position{robot | facing: @directions_to_the_left[facing]}
  end

  @doc """
  Moves the robot to the north, but prevents it to fall
  """
  def move(%CLI.Position{x: _, y: y, facing: :north} = robot) when y < @table_top_y do
    %CLI.Position{robot | y: Enum.find(@robot_map_y_atom_to_num, fn {_, val} -> val == Map.get(@robot_map_y_atom_to_num, y) + 1 end) |> elem(0)}
  end

  @doc """
  Moves the robot to the east, but prevents it to fall
  """
  def move(%CLI.Position{x: x, y: _, facing: :east} = robot) when x < @table_top_x do
    %CLI.Position{robot | x: x + 1}
  end

  @doc """
  Moves the robot to the south, but prevents it to fall
  """
  def move(%CLI.Position{x: _, y: y, facing: :south} = robot) when y > :a do
    %CLI.Position{robot | y: Enum.find(@robot_map_y_atom_to_num, fn {_, val} -> val == Map.get(@robot_map_y_atom_to_num, y) - 1 end) |> elem(0)}
  end

  @doc """
  Moves the robot to the west, but prevents it to fall
  """
  def move(%CLI.Position{x: x, y: _, facing: :west} = robot) when x > 1 do
    %CLI.Position{robot | x: x - 1}
  end

  @doc """
  Does not change the position of the robot.
  This function used as fallback if the robot cannot move outside the table
  """
  def move(robot), do: robot

  def failure do
    raise "Connection has been lost"
  end
end
