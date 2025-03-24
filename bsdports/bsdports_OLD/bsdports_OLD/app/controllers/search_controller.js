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
  }

  beforeSearch() {
    this.portList.animate(
      this.fadeIn,
      this.fadeInTiming
    )
  }

  get fadeIn() {
    return [
      { opacity: 0 },
      { opacity: 1 }
    ]
  }

  get fadeInTiming() {
    return { duration: 300 }
  }

  get portList() {
    return document.getElementById("live_results")
  }
}

