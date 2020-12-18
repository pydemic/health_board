defmodule HealthBoard.Release.DataPuller.FluSyndrome.Parser do
  require Logger

  alias HealthBoard.Contexts
  alias HealthBoard.Contexts.Geo.Locations

  @ets_buckets :buckets
  @ets_cities :cities

  @confirmed_index 2
  @discarded_index 3
  @female_index 4

  @age_0_4_value 0
  @age_5_9_value 1
  @age_10_14_value 2
  @age_15_19_value 3
  @age_20_24_value 4
  @age_25_29_value 5
  @age_30_34_value 6
  @age_35_39_value 7
  @age_40_44_value 8
  @age_45_49_value 9
  @age_50_54_value 10
  @age_55_59_value 11
  @age_60_64_value 12
  @age_65_69_value 13
  @age_70_74_value 14
  @age_75_79_value 15
  @age_80_or_more_value 16

  @male_index @female_index + @age_80_or_more_value + 1
  @health_professional_index 38

  @residence Contexts.registry_location!(:residence)
  @notification Contexts.registry_location!(:notification)

  @spec ets_buckets :: atom
  def ets_buckets, do: @ets_buckets

  @spec setup :: :ok
  def setup do
    :ets.new(@ets_cities, [:set, :public, :named_table])

    [context: Locations.context!(:city)]
    |> Locations.list_by()
    |> Locations.preload_parent(:health_region)
    |> Enum.each(&:ets.insert_new(@ets_cities, {&1.id, Enum.at(&1.parents, 0).parent_id}))

    :ets.new(@ets_buckets, [:set, :public, :named_table])

    :ok
  end

  @spec parse({integer, String.t(), integer, list(String.t())}) :: {tuple, Date.t(), list(atom)} | nil
  def parse({file_index, file_name, line_index, line}) do
    with {:ok, {datetimes, cities_ids, classification, gender_age, is_health_professional}} <- extract_data(line),
         {:ok, date} <- identify_date(datetimes),
         {:ok, locations} <- identify_locations(cities_ids) do
      fields = identify_fields(classification, gender_age, is_health_professional)
      Enum.each(locations, &update_bucket(&1, date, fields))
    else
      {:error, error} ->
        Logger.error("[##{file_index} #{file_name}:#{line_index}] #{error}")
        nil
    end
  end

  defp extract_data(line) do
    [
      _id,
      notification_datetime,
      symptoms_datetime,
      _birth_date,
      _symptoms,
      is_health_professional,
      _cbo,
      _conditions,
      _test_state,
      _test_date,
      _test_type,
      test_result,
      _origin_country,
      gender,
      _residence_state,
      _residence_state_id,
      _residence_city,
      residence_city_id,
      _origin,
      _cnes,
      _notification_state,
      _notification_state_id,
      _notification_city,
      notification_city_id,
      _removed,
      _validated,
      age,
      _ending_date,
      _case_evolution,
      final_classification
    ] = line

    {
      :ok,
      {
        {symptoms_datetime, notification_datetime},
        {residence_city_id, notification_city_id},
        {test_result, final_classification},
        {gender, age},
        is_health_professional
      }
    }
  rescue
    error -> {:error, format_error(error, __STACKTRACE__)}
  end

  defp identify_date({symptoms_datetime, notification_datetime}) do
    case NaiveDateTime.from_iso8601(symptoms_datetime) do
      {:ok, datetime} ->
        {:ok, NaiveDateTime.to_date(datetime)}

      _error ->
        case NaiveDateTime.from_iso8601(notification_datetime) do
          {:ok, datetime} -> {:ok, NaiveDateTime.to_date(datetime)}
          _error -> {:error, ~s(Invalid datetimes: "#{symptoms_datetime}" "#{notification_datetime}")}
        end
    end
  end

  defp identify_locations({residence_city_id, notification_city_id}) do
    case {identify_city_locations(residence_city_id), identify_city_locations(notification_city_id)} do
      {nil, nil} -> {:error, ~s(Invalid city ids: "#{residence_city_id}" "#{notification_city_id}")}
      {locations, nil} -> {:ok, [{@residence, locations}]}
      {nil, locations} -> {:ok, [{@notification, locations}]}
      {locations, locations} -> {:ok, [{@residence, locations}, {@notification, locations}]}
      {rls, nls} -> {:ok, [{@residence, rls}, {@notification, nls}]}
    end
  end

  defp identify_city_locations(city_id) do
    case :ets.lookup(@ets_cities, String.to_integer(city_id)) do
      [locations] -> locations
      _records -> nil
    end
  rescue
    _error -> nil
  end

  defp identify_fields(classification, gender_age, is_health_professional) do
    []
    |> identify_gender_age_group(gender_age)
    |> identify_classification(classification)
    |> identify_health_professional(is_health_professional)
  end

  defp identify_gender_age_group(fields, {gender, age}) do
    case identify_gender(gender) do
      nil ->
        fields

      gender ->
        case identify_age_group(age) do
          nil -> fields
          age_group -> [gender + age_group | fields]
        end
    end
  end

  defp identify_gender(gender) do
    if gender != "" do
      gender
      |> String.first()
      |> String.upcase()
      |> case do
        "F" -> @female_index
        "M" -> @male_index
        _gender -> nil
      end
    else
      nil
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp identify_age_group(age) do
    if age != "" do
      age = String.to_integer(age)

      cond do
        age <= 4 -> @age_0_4_value
        age <= 9 -> @age_5_9_value
        age <= 14 -> @age_10_14_value
        age <= 19 -> @age_15_19_value
        age <= 24 -> @age_20_24_value
        age <= 29 -> @age_25_29_value
        age <= 34 -> @age_30_34_value
        age <= 39 -> @age_35_39_value
        age <= 44 -> @age_40_44_value
        age <= 49 -> @age_45_49_value
        age <= 54 -> @age_50_54_value
        age <= 59 -> @age_55_59_value
        age <= 64 -> @age_60_64_value
        age <= 69 -> @age_65_69_value
        age <= 74 -> @age_70_74_value
        age <= 79 -> @age_75_79_value
        true -> @age_80_or_more_value
      end
    else
      nil
    end
  rescue
    _error -> nil
  end

  defp identify_classification(fields, {test_result, final_classification}) do
    case identify_test_result(test_result) do
      @discarded_index -> [identify_final_classification(final_classification) | fields]
      classification -> [classification | fields]
    end
  end

  defp identify_test_result(test_result) do
    if test_result != "" do
      test_result
      |> String.first()
      |> String.upcase()
      |> case do
        "P" -> @confirmed_index
        _char -> @discarded_index
      end
    else
      @discarded_index
    end
  end

  defp identify_final_classification(final_classification) do
    if final_classification != "" do
      final_classification
      |> String.first()
      |> String.upcase()
      |> case do
        "C" -> @confirmed_index
        _char -> @discarded_index
      end
    else
      @discarded_index
    end
  end

  defp identify_health_professional(fields, is_health_professional) do
    if is_health_professional != "" do
      is_health_professional
      |> String.first()
      |> String.upcase()
      |> case do
        "S" -> [@health_professional_index | fields]
        _char -> fields
      end
    else
      fields
    end
  end

  defp update_bucket({registry_context, {city_id, health_region_id}}, date, fields) do
    key = {registry_context, city_id, date}

    try do
      Enum.each(fields, &:ets.update_counter(@ets_buckets, key, {&1, 1}))
    rescue
      _error -> :ets.insert(@ets_buckets, new_bucket_record(key, health_region_id, fields))
    end
  end

  defp new_bucket_record(key, health_region_id, fields) do
    {
      key,
      health_region_id,
      if(2 in fields, do: 1, else: 0),
      if(3 in fields, do: 1, else: 0),
      if(4 in fields, do: 1, else: 0),
      if(5 in fields, do: 1, else: 0),
      if(6 in fields, do: 1, else: 0),
      if(7 in fields, do: 1, else: 0),
      if(8 in fields, do: 1, else: 0),
      if(9 in fields, do: 1, else: 0),
      if(10 in fields, do: 1, else: 0),
      if(11 in fields, do: 1, else: 0),
      if(12 in fields, do: 1, else: 0),
      if(13 in fields, do: 1, else: 0),
      if(14 in fields, do: 1, else: 0),
      if(15 in fields, do: 1, else: 0),
      if(16 in fields, do: 1, else: 0),
      if(17 in fields, do: 1, else: 0),
      if(18 in fields, do: 1, else: 0),
      if(19 in fields, do: 1, else: 0),
      if(20 in fields, do: 1, else: 0),
      if(21 in fields, do: 1, else: 0),
      if(22 in fields, do: 1, else: 0),
      if(23 in fields, do: 1, else: 0),
      if(24 in fields, do: 1, else: 0),
      if(25 in fields, do: 1, else: 0),
      if(26 in fields, do: 1, else: 0),
      if(27 in fields, do: 1, else: 0),
      if(28 in fields, do: 1, else: 0),
      if(29 in fields, do: 1, else: 0),
      if(30 in fields, do: 1, else: 0),
      if(31 in fields, do: 1, else: 0),
      if(32 in fields, do: 1, else: 0),
      if(33 in fields, do: 1, else: 0),
      if(34 in fields, do: 1, else: 0),
      if(35 in fields, do: 1, else: 0),
      if(36 in fields, do: 1, else: 0),
      if(37 in fields, do: 1, else: 0),
      if(38 in fields, do: 1, else: 0)
    }
  end

  defp format_error(error, stacktrace) do
    Exception.message(error) <> "\n" <> Exception.format_stacktrace(stacktrace)
  end
end
