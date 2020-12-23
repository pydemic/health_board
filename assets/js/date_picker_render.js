export const renderDatePicker = (datetime) => {
  document.addEventListener("DOMContentLoaded", function(){
    const covidStartDay = 1582686000000 // 26/02/2020
    const today = Date.now()
    let yesterday = new Date()
    yesterday.setDate(yesterday.getDate()-1)

    const basicOptions = {
      dateFormat:"dd/mm/YYYY",
      dateBlacklist: false,
      position: "bottom",
      timeFormat: false,
      locale: "pt_BR"
    }

    datetime("#date_date_picker", {
      ...basicOptions,
      dateRanges: [
        {
          start: covidStartDay,
          end: today,
          days: true
        }
      ],
    })

    datetime("#from_date_picker", {
      ...basicOptions,
      today: false,
      dateRanges: [
          {
            start: covidStartDay,
            end: yesterday,
            days: true
          }
      ],
    })
  
    datetime("#to_date_picker", {
      ...basicOptions,
      dateRanges: [
        {
          start: covidStartDay,
          end: today,
          days: true
        }
      ],
    })
  });
}
