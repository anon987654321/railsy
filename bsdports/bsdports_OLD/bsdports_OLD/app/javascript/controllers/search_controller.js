import ApplicationController from "./application_controller"

export default class extends ApplicationController {
  search(event) {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      this.stimulate("Search#search", event.target.value)
    }, 200)
  }

  reset(event) {
    event.preventDefault()
    this.stimulate("Search#search")

    document.getElementById("search").classList.remove("active")
  }

  beforeSearch() {
    this.List.animate(
      this.fadeIn,
      this.fadeInTiming
    )
  }

  get fadeIn() {
    return [
      { opacity: 0 },
      { opacity: 1 },

      document.getElementById("search").classList.add("active")
    ]
  }

  get fadeInTiming() {
    return { duration: 300 }
  }

  get List() {
    return document.getElementById("live_results")
  }
}

