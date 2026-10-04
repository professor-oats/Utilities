const video = document.querySelector("video");

const stream =
    video.captureStream?.() ||
    video.mozCaptureStream?.();

console.log("Stream:", stream);

console.log(
    "Video tracks:",
    stream.getVideoTracks().map(t => ({
        id: t.id,
        kind: t.kind,
        label: t.label,
        enabled: t.enabled,
        readyState: t.readyState,
        settings: t.getSettings()
    }))
);

console.log(
    "Audio tracks:",
    stream.getAudioTracks().map(t => ({
        id: t.id,
        kind: t.kind,
        label: t.label,
        enabled: t.enabled,
        readyState: t.readyState,
        settings: t.getSettings()
    }))
);

const recorder = new MediaRecorder(stream);
const chunks = [];

recorder.ondataavailable = e => {
    if (e.data.size > 0) chunks.push(e.data);
};

recorder.onstop = () => {
    const blob = new Blob(chunks, { type: recorder.mimeType });

    console.log("MIME:", recorder.mimeType);
    console.log("Size:", blob.size);

    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");

    a.href = url;
    a.download = "test-capture.webm";
    a.click();

    setTimeout(() => URL.revokeObjectURL(url), 10000);
};

console.log("Supported MIME types:");

for (const type of [
    "video/webm;codecs=vp9,opus",
    "video/webm;codecs=vp8,opus",
    "video/webm"
]) {
    console.log(type, MediaRecorder.isTypeSupported(type));
}

recorder.start(1000);

console.log("RECORDING");
