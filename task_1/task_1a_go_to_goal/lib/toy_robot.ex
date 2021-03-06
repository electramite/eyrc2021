defmodule ToyRobot do
  # max x-coordinate of table top
  @table_top_x 5
  # max y-coordinate of table top
  @table_top_y :e
  # mapping of y-coordinates
  @robot_map_y_atom_to_num %{:a => 1, :b => 2, :c => 3, :d => 4, :e => 5}

  # mapping of facing
  @robot_facing_to_num %{:east => 1, :south => 2, :west => 3, :north => 4}
  @doc """
  Places the robot to the default position of (1, A, North)

  Examples:

      iex> ToyRobot.place
      {:ok, %ToyRobot.Position{facing: :north, x: 1, y: :a}}
  """
  def place do
    {:ok, %ToyRobot.Position{}}
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

      iex> ToyRobot.place(1, :b, :south)
      {:ok, %ToyRobot.Position{facing: :south, x: 1, y: :b}}

      iex> ToyRobot.place(-1, :f, :north)
      {:failure, "Invalid position"}

      iex> ToyRobot.place(3, :c, :north_east)
      {:failure, "Invalid facing direction"}
  """
  def place(x, y, facing) do
    {:ok, %ToyRobot.Position{x: x, y: y, facing: facing}}
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

  def stop(_robot, goal_x, goal_y, _cli_proc_name) when goal_x < 1 or goal_y < :a or goal_x > @table_top_x or goal_y > @table_top_y do
    {:failure, "Invalid STOP position"}
  end


  @doc """
  Provide STOP position to the robot as given location of (x, y) and plan the path from START to STOP.
  Passing the CLI Server process name that will be used to send robot's current status after each action is taken.
  """
  def mod(num) do
    if num < 0 do
      num = - num
    else
      num
    end
  end
  # make the facing towards east or west accordingly
  def rotate_for_x(del_x, robot) do
    facing_2_the_right = %{north: :east, east: :south, south: :west, west: :north}
    right_facing = facing_2_the_right[robot.facing]
    if del_x>0 do # turn east
      del_d = @robot_facing_to_num[robot.facing] - @robot_facing_to_num[:east]
      if right_facing == :east do # turn right
        robot = right(robot)
        send_robot_status(robot, :cli_robot_state)
      else  # turn left
        if del_d == 2 do
          robot = left(robot)
          send_robot_status(robot, :cli_robot_state)
          robot = left(robot)
          send_robot_status(robot, :cli_robot_state)
        end
        if del_d == 1 or del_d == 3 do
          robot = left(robot)
          send_robot_status(robot, :cli_robot_state)
        end
      end
    end
    if del_x < 0 do # turn west
      del_d = @robot_facing_to_num[robot.facing] - @robot_facing_to_num[:west]
      del_d = mod(del_d)
      if right_facing == :west do
        robot = right(robot)
        send_robot_status(robot, :cli_robot_state)
      else
        if del_d == 2 do
          robot = left(robot)
          send_robot_status(robot, :cli_robot_state)
          robot = left(robot)
          send_robot_status(robot, :cli_robot_state)
        end
        if del_d == 1 or del_d == 3 do
          robot = left(robot)
          send_robot_status(robot, :cli_robot_state)
        end
      end
    end
  end
  # make the facing towards north or south accordingly
  def rotate_for_y(del_y, robot) do
    facing_2_the_right = %{north: :east, east: :south, south: :west, west: :north}
    right_facing = facing_2_the_right[robot.facing]
    if del_y>0 do # turn north
      del_d = @robot_facing_to_num[robot.facing] - @robot_facing_to_num[:north]
      del_d = mod(del_d)
      if right_facing == :north do # turn right
        robot = right(robot)
        send_robot_status(robot, :cli_robot_state)
      else  # turn left
        if del_d == 2 do
          robot = left(robot)
          send_robot_status(robot, :cli_robot_state)
          robot = left(robot)
          send_robot_status(robot, :cli_robot_state)
        end
        if del_d == 1 or del_d == 3 do
          robot = left(robot)
          send_robot_status(robot, :cli_robot_state)
        end
      end
    end
    if del_y < 0 do # turn south
      del_d = @robot_facing_to_num[robot.facing] - @robot_facing_to_num[:south]
      del_d = mod(del_d)
      if right_facing == :south do
        robot = right(robot)
        send_robot_status(robot, :cli_robot_state)
      else
        if del_d == 2 do
          robot = left(robot)
          send_robot_status(robot, :cli_robot_state)
          robot = left(robot)
          send_robot_status(robot, :cli_robot_state)
        end
        if del_d == 1 or del_d == 3 do
          robot = left(robot)
          send_robot_status(robot, :cli_robot_state)
        end
      end
    end
  end

  def move_along_xy(del_x, robot) when del_x <= 1 do
    robot = move(robot)
    send_robot_status(robot, :cli_robot_state)
  end
  def move_along_xy(del_x, robot) do
    robot = move(robot)
    send_robot_status(robot, :cli_robot_state)
    move_along_xy(del_x - 1, robot)
  end
  def final_facing(del_x, del_y, robot) do
    cond do
      (del_y > 0) and (del_x > 0) -> %ToyRobot.Position{robot | facing: :east}
      (del_y > 0) and (del_x < 0) -> %ToyRobot.Position{robot | facing: :west}
      (del_y < 0) and (del_x > 0) -> %ToyRobot.Position{robot | facing: :east}
      (del_y < 0) and (del_x < 0) -> %ToyRobot.Position{robot | facing: :west}
      (del_y == 0) and (del_x > 0) -> %ToyRobot.Position{robot | facing: :east}
      (del_y == 0) and (del_x < 0) -> %ToyRobot.Position{robot | facing: :west}
      (del_y > 0) and (del_x == 0) -> %ToyRobot.Position{robot | facing: :north}
      (del_y < 0) and (del_x == 0) -> %ToyRobot.Position{robot | facing: :south}
      (del_y == 0) and (del_x == 0) -> robot
    end
  end
  def stop(robot, goal_x, goal_y, cli_proc_name) do
    ###########################
    ## complete this funcion ##
    ###########################

    del_x = goal_x - robot.x
    del_y = @robot_map_y_atom_to_num[goal_y] - @robot_map_y_atom_to_num[robot.y]
    send_robot_status(robot, :cli_robot_state)
    rotate_for_y(del_y, robot)
    if del_y > 0 do  # north
      robot = %ToyRobot.Position{robot | facing: :north}
      move_along_xy(del_y, robot)
      robot = %ToyRobot.Position{robot | y: goal_y}
      if del_x > 0 do
        rotate_for_x(del_x, robot)
        robot = %ToyRobot.Position{robot | facing: :east}
        move_along_xy(del_x, robot)
      end
      if del_x < 0 do
        rotate_for_x(del_x, robot)
        robot = %ToyRobot.Position{robot | facing: :west}
        move_along_xy(-del_x, robot)
      end
    end
    if del_y < 0 do
      robot = %ToyRobot.Position{robot | facing: :south}
      move_along_xy(-del_y, robot)
      robot = %ToyRobot.Position{robot | y: goal_y}
      if del_x > 0 do
        rotate_for_x(del_x, robot)
        robot = %ToyRobot.Position{robot | facing: :east}
        move_along_xy(del_x, robot)
      end
      if del_x < 0 do
        rotate_for_x(del_x, robot)
        robot = %ToyRobot.Position{robot | facing: :west}
        move_along_xy(-del_x, robot)
      end
    end
    if del_y == 0 do
      if del_x > 0 do
        rotate_for_x(del_x, robot)
        robot = %ToyRobot.Position{robot | facing: :east}
        move_along_xy(del_x, robot)
      end
      if del_x < 0 do
        rotate_for_x(del_x, robot)
        robot = %ToyRobot.Position{robot | facing: :west}
        move_along_xy(-del_x, robot)
      end
    end
    robot = %ToyRobot.Position{robot | x: goal_x, y: goal_y}
    robot = final_facing(del_x, del_y, robot)
    {:ok, robot}
  end

  @doc """
  Send Toy Robot's current status i.e. location (x, y) and facing
  to the CLI Server process after each action is taken.
  """
  def send_robot_status(%ToyRobot.Position{x: x, y: y, facing: facing} = _robot, cli_proc_name) do
    send(cli_proc_name, {:toyrobot_status, x, y, facing})
    # IO.puts("Sent by Toy Robot Client: #{x}, #{y}, #{facing}")
  end

  @doc """
  Provides the report of the robot's current position

  Examples:

      iex> {:ok, robot} = ToyRobot.place(2, :b, :west)
      iex> ToyRobot.report(robot)
      {2, :b, :west}
  """
  def report(%ToyRobot.Position{x: x, y: y, facing: facing} = _robot) do
    {x, y, facing}
  end

  @directions_to_the_right %{north: :east, east: :south, south: :west, west: :north}
  @doc """
  Rotates the robot to the right.
  """
  def right(%ToyRobot.Position{facing: facing} = robot) do
    %ToyRobot.Position{robot | facing: @directions_to_the_right[facing]}
  end

  @directions_to_the_left Enum.map(@directions_to_the_right, fn {from, to} -> {to, from} end)
  @doc """
  Rotates the robot to the left.
  """
  def left(%ToyRobot.Position{facing: facing} = robot) do
    %ToyRobot.Position{robot | facing: @directions_to_the_left[facing]}
  end

  @doc """
  Moves the robot to the north, but prevents it to fall.
  """
  def move(%ToyRobot.Position{x: _, y: y, facing: :north} = robot) when y < @table_top_y do
    %ToyRobot.Position{robot | y: Enum.find(@robot_map_y_atom_to_num, fn {_, val} -> val == Map.get(@robot_map_y_atom_to_num, y) + 1 end) |> elem(0)}
  end

  @doc """
  Moves the robot to the east, but prevents it to fall.
  """
  def move(%ToyRobot.Position{x: x, y: _, facing: :east} = robot) when x < @table_top_x do
    %ToyRobot.Position{robot | x: x + 1}
  end

  @doc """
  Moves the robot to the south, but prevents it to fall.
  """
  def move(%ToyRobot.Position{x: _, y: y, facing: :south} = robot) when y > :a do
    %ToyRobot.Position{robot | y: Enum.find(@robot_map_y_atom_to_num, fn {_, val} -> val == Map.get(@robot_map_y_atom_to_num, y) - 1 end) |> elem(0)}
  end

  @doc """
  Moves the robot to the west, but prevents it to fall.
  """
  def move(%ToyRobot.Position{x: x, y: _, facing: :west} = robot) when x > 1 do
    %ToyRobot.Position{robot | x: x - 1}
  end

  @doc """
  Does not change the position of the robot.
  This function used as fallback if the robot cannot move outside the table.
  """
  def move(robot), do: robot

  def failure do
    raise "Connection has been lost"
  end
end
