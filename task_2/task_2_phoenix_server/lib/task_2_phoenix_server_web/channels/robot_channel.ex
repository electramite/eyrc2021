defmodule Task2PhoenixServerWeb.RobotChannel do
  use Phoenix.Channel
  @robot_map_y_atom_to_num %{:a => 1, :b => 2, :c => 3, :d => 4, :e => 5}

  @doc """
  Handler function for any Client joining the channel with topic "robot:status".
  Reply or Acknowledge with socket PID received from the Client.
  """
  def join("robot:status", _params, socket) do
    {:ok, socket}
  end

  @doc """
  Callback function for messages that are pushed to the channel with "robot:status" topic with an event named "new_msg".
  Receive the message from the Client, parse it to create another Map strictly of this format:
  %{ "left" => < left_value >, "bottom" => < bottom_value >, "face" => < face_value > }

  These values should be pixel locations for the robot's image to be displayed on the Dashboard
  corresponding to the various actions of the robot as recevied from the Client.

  Subscribe to the topic named "robot:update" on the Phoenix Server as PubSub and then
  broadcast the created Map of pixel locations, so that the ArenaLive module can update
  the robot's image and location on the Dashboard as soon as it receives the new data.

  Based on the message from the Client, determine the obstacle's presence in front of the robot
  and return the boolean value in this format {:ok, < true OR false >}.

  """
  alias Phoenix.PubSub
  def handle_in("new_msg", message, socket) do
    y_to_num = %{"a" => 1, "b" => 2, "c" => 3, "d" => 4, "e" => 5}
    image_name = %{"west" => "robot_facing_west.png", "east" => "robot_facing_east.png", "north" => "robot_facing_north.png", "south" => "robot_facing_south.png",}
    left_value = (message["x"]-1)*150
    bottom_value = (y_to_num["#{message["y"]}"]-1)*150
    face_value = image_name["#{message["facing"]}"]

    msg = %{ "left" => left_value, "bottom" => bottom_value, "face" => face_value}
    PubSub.subscribe Task2PhoenixServer.PubSub, "robot:update"
    PubSub.broadcast Task2PhoenixServer.PubSub, "robot:update",  msg

    ###########################
    ## complete this funcion ##
    ###########################

    # determine the obstacle's presence in front of the robot and return the boolean value
    is_obs_ahead = Task2PhoenixServerWeb.FindObstaclePresence.is_obstacle_ahead?("#{message["x"]}", "#{message["y"]}", "#{message["facing"]}")

    # file object to write each action taken by Toy Robot
    {:ok, out_file} = File.open("task_2_output.txt", [:append])
    # write the robot actions to a text file
    IO.binwrite(out_file, "#{message["x"]}, #{message["y"]}, #{message["face"]}\n")

    {:reply, {:ok, is_obs_ahead}, socket}
  end
end
