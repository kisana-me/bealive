import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "capturedFrontImage", "capturedBackImage",
    "countdown", "currentCamera",
    "toggleCaptureButton", "toggleCameraButton",
    "backVideo", "frontVideo"
  ]

  connect() {
    this.photosTaken = { front: false, back: false }
    this.captureStarted = false
    this.previewing = false
    this.currentFacingMode = "user"
  }

  updateCurrentCameraLabel() {
    if (this.hasCurrentCameraTarget) {
      this.currentCameraTarget.textContent =
        this.currentFacingMode === "user" ? "セルフィ" : "アウト"
    }
  }

  toggleCamera() {
    this.currentFacingMode = this.currentFacingMode === "user" ? "environment" : "user"
    this.updateCurrentCameraLabel()
    if (this.previewing) {
      this.startCamera({ facingMode: this.currentFacingMode })
    }
  }

  async toggleCaptureFlow() {
    if (!this.captureStarted) {
      await this.startPreview()
    } else {
      this.toggleCameraButtonTarget.disabled = true
      this.toggleCaptureButtonTarget.disabled = true
      await this.startCapture()
      this.toggleCaptureButtonTarget.textContent = "撮り直し"
      this.toggleCaptureButtonTarget.disabled = false
      this.captureStarted = false
    }
  }

  async startPreview() {
    await this.startCamera({ facingMode: this.currentFacingMode })
    this.toggleCameraButtonTarget.disabled = false
    this.toggleCaptureButtonTarget.textContent = "撮影開始"
    this.capturedFrontImageTarget.style.display = "none"
    this.capturedBackImageTarget.style.display = "none"
    this.captureStarted = true
    this.previewing = true
  }

  async startCapture() {
    this.photosTaken = { front: false, back: false }

    const startWithUser = this.currentFacingMode === "user"
    const devices = await navigator.mediaDevices.enumerateDevices()
    const videoDevices = devices.filter(device => device.kind === "videoinput")
    const useSingleCamera = videoDevices.length <= 1

    const first = startWithUser ? "user" : "environment"
    const second = startWithUser ? "environment" : "user"
    const sequence = useSingleCamera ? [first, first] : [first, second]

    for (let i = 0; i < sequence.length; i++) {
      await this.startCamera({ facingMode: sequence[i] })
      await this.waitForVideoReady()
      await this.countdownBeforeCapture()

      const isFirst = i === 0
      const role = startWithUser
        ? (isFirst ? "front" : "back")
        : (isFirst ? "back" : "front")

      await this.capturePhoto(role)
    }
    this.countdownTarget.textContent = ""

    this.stopCamera()
    this.previewing = false
    this.checkCaptureComplete()
  }

  async startCamera({ facingMode }) {
    this.stopCamera()
    this.currentFacingMode = facingMode
    this.updateCurrentCameraLabel()

    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode } })
      const video = this.videoElement
      video.srcObject = this.stream
      await video.play()
    } catch (e) {
      console.error("カメラ起動失敗", e)
    }
  }

  stopCamera() {
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop())
      this.stream = null
    }

    if (this.hasBackVideoTarget) {
      this.backVideoTarget.pause()
      this.backVideoTarget.srcObject = null
      this.backVideoTarget.style.display = "none"
    }

    if (this.hasFrontVideoTarget) {
      this.frontVideoTarget.pause()
      this.frontVideoTarget.srcObject = null
      this.frontVideoTarget.style.display = "none"
    }
  }

  async waitForVideoReady() {
    return new Promise(resolve => {
      if (this.videoElement.readyState >= 3) {
        resolve()
      } else {
        this.videoElement.onloadedmetadata = () => resolve()
      }
    })
  }

  async countdownBeforeCapture() {
    const el = this.countdownTarget
    for (let i = 3; i >= 1; i--) {
      el.textContent = i
      await this.sleep(1000)
    }
    el.textContent = "カメラ切り替え中"
  }

  async capturePhoto(role) {
    const video = this.videoElement
    const originalWidth = video.videoWidth
    const originalHeight = video.videoHeight
    const targetAspect = 2 / 3
    let cropWidth = originalWidth
    let cropHeight = cropWidth / targetAspect

    if (cropHeight > originalHeight) {
      cropHeight = originalHeight
      cropWidth = cropHeight * targetAspect
    }

    const cropX = (originalWidth - cropWidth) / 2
    const cropY = (originalHeight - cropHeight) / 2

    const canvas = document.createElement("canvas")
    canvas.width = cropWidth
    canvas.height = cropHeight

    const ctx = canvas.getContext("2d")
    ctx.drawImage(
      video,
      cropX, cropY, cropWidth, cropHeight,
      0, 0, cropWidth, cropHeight
    )

    const dataUrl = canvas.toDataURL("image/png")
    const blob = await (await fetch(dataUrl)).blob()
    const file = new File([blob], `${role}_photo.png`, { type: "image/png" })
    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)

    const fieldId = role === "front" ? "front_image_field" : "back_image_field"
    const imgTarget = role === "front" ? this.capturedFrontImageTarget : this.capturedBackImageTarget
    const fileField = document.getElementById(fieldId)

    imgTarget.src = dataUrl
    imgTarget.style.display = "block"
    fileField.files = dataTransfer.files

    this.photosTaken[role] = true
  }


  checkCaptureComplete() {
    if (this.photosTaken.front && this.photosTaken.back) {
      console.log("📸 撮影完了")
    }
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  get videoElement() {
    const isFront = this.currentFacingMode === "user"
    const front = this.hasFrontVideoTarget ? this.frontVideoTarget : null
    const back = this.hasBackVideoTarget ? this.backVideoTarget : null

    if (front) front.style.display = isFront ? "block" : "none"
    if (back) back.style.display = isFront ? "none" : "block"
    return isFront ? front : back
  }
}
