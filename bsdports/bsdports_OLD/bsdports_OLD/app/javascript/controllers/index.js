import { application } from "./application"
import CableReady from "cable_ready"
import StimulusReflex from "stimulus_reflex"
import consumer from "../channels/consumer"
import controller from "../controllers/application_controller"

application.consumer = consumer
CableReady.initialize({ consumer })

StimulusReflex.initialize(application, { controller, isolate: true })
// StimulusReflex.debug = process.env.RAILS_ENV === "development"

// import Carousel from "stimulus-carousel"
// application.register("carousel", Carousel)

