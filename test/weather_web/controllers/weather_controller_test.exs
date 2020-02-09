defmodule WeatherWeb.WeatherControllerTest do
  use WeatherWeb.ConnCase
  import Mock

  alias Weather.DarkSkyClient

  test "GET /weather returns the current and weekly forecast", %{conn: conn} do
    get_forecast_mock = fn coordinates ->
      %{
        "currently" => %{
          "icon" => "fog",
          "summary" => "Foggy",
          "temperature" => 36.46,
          "time" => 1_581_220_393,
          "windBearing" => 87,
          "windSpeed" => 2.91,
          "precipProbability" => 0,
        },
        "daily" => %{
          "data" => [
            %{
              "icon" => "rain",
              "temperatureMin" => 31.12,
              "time" => 1_581_138_000,
              "temperatureMax" => 43.69,
              "summary" => "Light rain in the morning and afternoon."
            }
          ],
          "icon" => "rain",
          "summary" => "Light rain today through Thursday."
        }
      }
    end

    System.put_env("DARK_SKY_KEY", "banana")

    response =
      Mock.with_mock DarkSkyClient, get_forecast: get_forecast_mock do
        conn = get(conn, "/weather", %{"latitude" => 43, "longitude" => 54})

        assert json_response(conn, 200) == %{
                 "daily" => [
                   %{
                     "date" => "2020-2-8",
                     "description" => "Light rain in the morning and afternoon.",
                     "temperature" => %{"high" => 43.69, "low" => 31.12},
                     "type" => "rain"
                   }
                 ],
                 "date" => "2020-2-9",
                 "description" => "Foggy",
                 "precip_prob" => 0,
                 "temperature" => 36.46,
                 "type" => "fog",
                 "wind" => %{"bearing" => 87, "speed" => 2.91}
               }
      end
  end
end
