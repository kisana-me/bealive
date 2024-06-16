import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['frontPhotoButton', 'backPhotoButton', 'capturedFrontImage', 'capturedBackImage']

  connect() {
    console.log("Camera controller connected")
    this.initializeCamera()
  }
  disconnect() {
    const videoElement = this.videoElement
    const stream = videoElement.srcObject
    if (stream) {
      const tracks = stream.getTracks()
      tracks.forEach(track => track.stop())
      videoElement.srcObject = null
    }
  }
  reloadCameraDevices() {
    const selectElement = this.element.querySelector('select')
    selectElement.innerHTML = ''
    this.initializeCamera()
  }
  initializeCamera() {
    const selectElement = this.element.querySelector('select')
    navigator.mediaDevices.enumerateDevices()
      .then(devices => {
        devices.forEach(device => {
          if (device.kind === 'videoinput') {
            const option = document.createElement('option')
            option.value = device.deviceId
            option.text = device.label || `Camera ${selectElement.options.length + 1}`
            selectElement.appendChild(option)
            console.log(`Device ID: ${device.deviceId}, Label: ${device.label}, Facing mode: ${device.facingMode}`);
          }
        })
      })
      .catch(error => {
        console.error('Error enumerating media devices.', error)
      })
  }
  openCamera() {
    const deviceId = this.selectedDeviceId()
    if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
      navigator.mediaDevices.getUserMedia({ video: { deviceId: deviceId, aspectRatio: 4/3 } })//
        .then((stream) => {
          this.videoElement.srcObject = stream
          this.videoElement.play()
          this.frontPhotoButtonTarget.disabled = false
          this.backPhotoButtonTarget.disabled = false
          //this.reloadCameraDevices()
        })
        .catch((error) => {
          console.error('Error accessing media devices.', error)
        })
    }
  }
  selectedDeviceId() {
    const selectElement = this.element.querySelector('select')
    return selectElement.value
  }
  takePhoto(fieldId, buttonTarget, ImageTarget) {
    const canvas = document.createElement('canvas')
    const video = this.videoElement
    canvas.width = video.videoWidth
    canvas.height = video.videoHeight
    const context = canvas.getContext('2d')
    context.drawImage(video, 0, 0, canvas.width, canvas.height)
    const imageDataUrl = canvas.toDataURL('image/png')
    const imgElement = ImageTarget
    imgElement.src = imageDataUrl
    imgElement.style.display = 'block'
    fetch(imageDataUrl)
      .then(res => res.blob())
      .then(blob => {
        const file = new File([blob], 'captured_image.png', { type: 'image/png' })
        const dataTransfer = new DataTransfer()
        dataTransfer.items.add(file)
        const hiddenFileField = document.getElementById(fieldId)
        hiddenFileField.files = dataTransfer.files
      })
    buttonTarget.disabled = true
  }

  // 撮影する, 自動でカメラ切り替えて連続撮影に？
  takeFrontPhoto() {
    this.takePhoto('front_image_field', this.frontPhotoButtonTarget, this.capturedFrontImageTarget)
  }
  takeBackPhoto() {
    this.takePhoto('back_image_field', this.backPhotoButtonTarget, this.capturedBackImageTarget)
  }

  get videoElement() {
    return this.element.querySelector('video')
  }
}
