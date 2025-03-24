import ApplicationController from "./application_controller";
import { useIntersection } from "stimulus-use";

export default class extends ApplicationController {
  static targets = ["button"];

  connect() {
    super.connect();
    useIntersection(this, { element: this.buttonTarget });
  }

  appear() {
    this.buttonTarget.disabled = true;
    this.stimulate("ArticlesInfiniteScroll#load_more", this.buttonTarget);
  }
}

